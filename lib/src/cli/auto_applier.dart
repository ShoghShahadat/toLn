// lib/src/cli/auto_applier.dart

import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;

/// A class that automatically adds `.toLn()` to display strings, adds necessary
/// imports, and configures the main() function for initialization.
class AutoApplier {
  final String projectPath;
  final bool dryRun;

  AutoApplier(this.projectPath, {this.dryRun = false});

  Future<void> run() async {
    final libDir = Directory(p.join(projectPath, 'lib'));
    if (!await libDir.exists()) {
      stdout.writeln('Error: "lib" directory not found.');
      return;
    }

    final collection =
        AnalysisContextCollection(includedPaths: [libDir.absolute.path]);

    for (final context in collection.contexts) {
      for (final filePath in context.contextRoot.analyzedFiles()) {
        if (filePath.endsWith('.dart')) {
          await _processFile(filePath, context.currentSession.getResolvedUnit);
        }
      }
    }
  }

  Future<void> _processFile(String path,
      Future<SomeResolvedUnitResult> Function(String) getResolvedUnit) async {
    final result = await getResolvedUnit(path);

    if (result is! ResolvedUnitResult) {
      stdout.writeln(
          '  \x1B[31m[ERROR]\x1B[0m Could not fully resolve ${p.basename(path)}. Skipping file.');
      return;
    }

    final astUnit = result.unit;
    final content = result.content;

    final visitor = _ModificationVisitor();
    astUnit.visitChildren(visitor);

    if (p.basename(path).startsWith('main')) {
      visitor.checkForMainFunction(astUnit);
    }

    if (visitor.needsTolnImport && !visitor.tolnImportExists) {
      final lastImport =
          astUnit.directives.whereType<ImportDirective>().lastOrNull;
      final offset = lastImport?.end ?? 0;
      final text =
          (offset > 0 ? '\n' : '') + "import 'package:toln/toln.dart';\n";
      visitor.modifications.add((offset: offset, text: text));
    }

    if (visitor.modifications.isEmpty) {
      return;
    }

    stdout.writeln(
        '  \x1B[33m[CHANGES]\x1B[0m Found ${visitor.modifications.length} potential modification(s) in ${p.basename(path)}');

    if (dryRun) {
      return;
    }

    String newContent = content;
    visitor.modifications.sort((a, b) => b.offset.compareTo(a.offset));
    for (final mod in visitor.modifications) {
      newContent = newContent.substring(0, mod.offset) +
          mod.text +
          newContent.substring(mod.offset);
    }

    final formattedContent = DartFormatter().format(newContent);
    await File(path).writeAsString(formattedContent);
  }
}

/// A visitor that finds all necessary modifications.
class _ModificationVisitor extends RecursiveAstVisitor<void> {
  final List<({int offset, String text})> modifications = [];
  bool tolnImportExists = false;
  bool needsTolnImport = false;

  final Map<String, List<String>> _targetWidgets = {
    'Text': [''],
    'Tooltip': ['message'],
    'FloatingActionButton': ['tooltip'],
    'IconButton': ['tooltip'],
    'SnackBar': ['content'],
    'AlertDialog': ['title', 'content'],
    'MaterialApp': ['title'],
    'InputDecoration': [
      'labelText',
      'hintText',
      'helperText',
      'errorText',
      'prefixText',
      'suffixText',
      'label',
      'hint'
    ],
  };

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.uri.stringValue == 'package:toln/toln.dart') {
      tolnImportExists = true;
    }
    super.visitImportDirective(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'toLn') {
      return;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type is InterfaceType) {
      final className = type.element.name;
      if (_targetWidgets.containsKey(className)) {
        _applyToLnToArguments(
            node.argumentList.arguments, _targetWidgets[className]!);
      }
    }
    super.visitInstanceCreationExpression(node);
  }

  void _applyToLnToArguments(
      NodeList<Expression> arguments, List<String> targetParamNames) {
    for (final arg in arguments) {
      Expression? stringExpression;
      if (targetParamNames.contains('') && arg is StringLiteral) {
        stringExpression = arg;
      } else if (arg is NamedExpression &&
          targetParamNames.contains(arg.name.label.name) &&
          arg.expression is StringLiteral) {
        stringExpression = arg.expression;
      }

      if (stringExpression != null) {
        final source = stringExpression.toSource();
        if (source.length > 2 && !source.endsWith('.toLn()')) {
          modifications.add((offset: stringExpression.end, text: '.toLn()'));
          needsTolnImport = true;
        }
      }
    }
  }

  /// Special logic to check and modify the main() function.
  void checkForMainFunction(CompilationUnit unit) {
    // --- THE FIX IS HERE! ---
    // Use a safe loop to find the main function instead of firstWhere with a faulty orElse.
    FunctionDeclaration? mainFunction;
    for (final declaration in unit.declarations) {
      if (declaration is FunctionDeclaration &&
          declaration.name.lexeme == 'main') {
        mainFunction = declaration;
        break; // Found it, no need to continue.
      }
    }

    // If no main function is found, do nothing.
    if (mainFunction == null) {
      return;
    }

    final mainBodyVisitor = _MainFunctionBodyVisitor();
    mainFunction.functionExpression.body.visitChildren(mainBodyVisitor);

    final body = mainFunction.functionExpression.body;
    if (body is BlockFunctionBody) {
      final offset = body.block.leftBracket.end;
      String textToInsert = '';

      if (!mainFunction.functionExpression.body.isAsynchronous) {
        modifications.add((offset: body.offset, text: ' async '));
      }
      if (!mainBodyVisitor.hasEnsureInitialized) {
        textToInsert += '\n  WidgetsFlutterBinding.ensureInitialized();';
      }
      if (!mainBodyVisitor.hasToLnInit) {
        textToInsert +=
            "\n  await ToLn.init(baseLocale: ''); // لطفا زبان فعلی برنامه فایل Base را وارد کنید\n";
        needsTolnImport = true;
      }

      if (textToInsert.isNotEmpty) {
        modifications.add((offset: offset, text: textToInsert));
      }
    }
  }
}

/// A dedicated, simple visitor to inspect the body of the main function.
/// --- UPDATED: Now uses semantic analysis for robust checking ---
class _MainFunctionBodyVisitor extends RecursiveAstVisitor<void> {
  bool hasEnsureInitialized = false;
  bool hasToLnInit = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final element = node.methodName.staticElement;
    if (element != null) {
      final enclosingElementName = element.enclosingElement?.name;
      final methodName = element.name;

      if (enclosingElementName == 'WidgetsFlutterBinding' &&
          methodName == 'ensureInitialized') {
        hasEnsureInitialized = true;
      }
      if (enclosingElementName == 'ToLn' && methodName == 'init') {
        hasToLnInit = true;
      }
    }
    // Continue visiting to check inside other expressions.
    super.visitMethodInvocation(node);
  }
}
