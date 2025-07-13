// lib/src/cli/extractor.dart

import 'dart:io';
import 'dart:convert';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;
import 'assistant.dart';

/// A class responsible for extracting all strings marked with `.toLn()`
/// from a Flutter project, and updating the translation files.
/// This version uses a full AST analysis for 100% accuracy.
class Extractor {
  final String projectPath;
  final String _localesPath;
  final File _baseFile;
  final File _keyMapFile;

  Map<String, String> _baseTranslations = {}; // key -> normalized_text
  Map<String, String> _keyMap = {}; // normalized_text -> key

  Extractor(this.projectPath)
      : _localesPath = p.join(projectPath, 'assets', 'locales'),
        _baseFile = File(p.join(projectPath, 'assets', 'locales', 'base.ln')),
        _keyMapFile =
            File(p.join(projectPath, 'assets', 'locales', 'key_map.ln'));

  Future<void> run() async {
    await Directory(_localesPath).create(recursive: true);
    await _loadExistingFiles();

    final Set<String> foundTexts = await _findTranslatableTextsWithAst();

    await _processTexts(foundTexts);
    await _saveFiles();
  }

  Future<void> _loadExistingFiles() async {
    if (await _baseFile.exists()) {
      final content = await _baseFile.readAsString();
      if (content.isNotEmpty) {
        _baseTranslations = Map<String, String>.from(json.decode(content));
      }
    }
    if (await _keyMapFile.exists()) {
      final content = await _keyMapFile.readAsString();
      if (content.isNotEmpty) {
        _keyMap = Map<String, String>.from(json.decode(content));
      }
    }
  }

  /// Finds translatable texts by parsing the Dart code into an AST.
  Future<Set<String>> _findTranslatableTextsWithAst() async {
    final Set<String> texts = {};
    final collection =
        AnalysisContextCollection(includedPaths: [p.join(projectPath, 'lib')]);

    for (final context in collection.contexts) {
      for (final filePath in context.contextRoot.analyzedFiles()) {
        if (!filePath.endsWith('.dart')) continue;

        final result = await context.currentSession.getResolvedUnit(filePath);
        if (result is ResolvedUnitResult) {
          final visitor = _TranslatableStringVisitor();
          result.unit.visitChildren(visitor);
          texts.addAll(visitor.foundTexts);
        }
      }
    }
    return texts;
  }

  Future<void> _processTexts(Set<String> texts) async {
    final RegExp variableRegex =
        RegExp(r'\$\{([^}]+)\}|\$([a-zA-Z_][a-zA-Z0-9_]*)');
    int nextKeyId =
        _baseTranslations.keys.where((k) => k.startsWith('keLn')).length + 1;

    for (final text in texts) {
      final normalizedText = text.replaceAll(variableRegex, r'$s');

      if (!_keyMap.containsKey(normalizedText)) {
        final similar = Assistant.findSimilarText(
            newText: normalizedText, existingKeyMap: _keyMap);

        if (similar != null) {
          stdout.writeln(
              '\x1B[34m[ASSISTANT]\x1B[0m New text "$normalizedText" is very similar to existing text "${similar.text}".');
          stdout.write(
              'Do you want to use the same key (${similar.key})? (Y/n): ');
          final answer = stdin.readLineSync()?.toLowerCase() ?? 'y';

          if (answer == 'y' || answer.isEmpty) {
            _keyMap[normalizedText] = similar.key;
            stdout.writeln(
                '  \x1B[32m[OK]\x1B[0m Reusing key ${similar.key} for the new text.');
            continue;
          }
        }

        final newKey = 'keLn$nextKeyId';
        _keyMap[normalizedText] = newKey;
        _baseTranslations[newKey] = normalizedText;
        nextKeyId++;
        stdout.writeln(
            '  \x1B[33m[NEW]\x1B[0m Found new text: "$text" -> Assigned key: $newKey');
      }
    }
  }

  Future<void> _saveFiles() async {
    final bool lnNameExisted = _baseTranslations.containsKey('ln_name');
    final String lnNameValue = _baseTranslations['ln_name'] ?? '';

    final orderedBaseTranslations = <String, String>{};
    orderedBaseTranslations['ln_name'] = lnNameValue;

    _baseTranslations.forEach((key, value) {
      if (key != 'ln_name') {
        orderedBaseTranslations[key] = value;
      }
    });

    if (!lnNameExisted) {
      stdout.writeln(
          '  \x1B[34m[INFO]\x1B[0m Added placeholder "ln_name" key to base.ln. Please fill it with the display name for your base language.');
    }

    final encoder = JsonEncoder.withIndent('  ');
    await _baseFile.writeAsString(encoder.convert(orderedBaseTranslations));
    await _keyMapFile.writeAsString(encoder.convert(_keyMap));
  }
}

/// An AST visitor that specifically looks for `.toLn()` method invocations
/// and extracts the string literal content it's being called on.
class _TranslatableStringVisitor extends RecursiveAstVisitor<void> {
  final Set<String> foundTexts = {};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Check if the method being called is exactly '.toLn()'
    if (node.methodName.name == 'toLn') {
      // The 'target' is the expression the method is called on.
      // We are interested if the target is any kind of string literal.
      if (node.target is StringLiteral) {
        final stringLiteral = node.target as StringLiteral;

        // --- THE FINAL, ROBUST FIX ---
        // Get the full source of the string literal (e.g., "'Hello ${name}!'")
        final fullSource = stringLiteral.toSource();

        // Strip the leading and trailing quotes.
        // This handles single, double, and triple quotes robustly.
        if (fullSource.startsWith('"""') && fullSource.endsWith('"""')) {
          foundTexts.add(fullSource.substring(3, fullSource.length - 3));
        } else if (fullSource.startsWith("'''") && fullSource.endsWith("'''")) {
          foundTexts.add(fullSource.substring(3, fullSource.length - 3));
        } else if (fullSource.isNotEmpty) {
          // Also handle raw strings (e.g., r'...')
          final startIndex = fullSource.startsWith('r') ? 2 : 1;
          foundTexts
              .add(fullSource.substring(startIndex, fullSource.length - 1));
        }
      }
    }
    // IMPORTANT: Continue visiting children to find nested invocations.
    super.visitMethodInvocation(node);
  }
}
