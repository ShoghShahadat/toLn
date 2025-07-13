// lib/src/cli/syncer.dart

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/// A class responsible for syncing translation files with the base.ln file.
/// It ensures all translation files have the same set of keys.
class Syncer {
  final String projectPath;
  final String _localesPath;
  final File _baseFile;

  Map<String, String> _baseTranslations = {};

  Syncer(this.projectPath)
      : _localesPath = p.join(projectPath, 'assets', 'locales'),
        _baseFile = File(p.join(projectPath, 'assets', 'locales', 'base.ln'));

  /// The main public method to run the sync process.
  Future<void> run() async {
    if (!await _baseFile.exists()) {
      throw FileSystemException(
          'base.ln file not found. Please run `extract` command first.');
    }

    final baseContent = await _baseFile.readAsString();
    _baseTranslations = Map<String, String>.from(json.decode(baseContent));

    final localesDir = Directory(_localesPath);
    await for (final file in localesDir.list()) {
      if (file is File &&
          file.path.endsWith('.ln') &&
          !file.path.endsWith('base.ln') &&
          !p.basename(file.path).startsWith('key_map')) {
        await _syncFile(file);
      }
    }
  }

  /// Syncs a single translation file with the base translations.
  Future<void> _syncFile(File file) async {
    final content = await file.readAsString();
    Map<String, String> translations;

    try {
      if (content.trim().isEmpty) {
        translations = {};
      } else {
        translations = Map<String, String>.from(json.decode(content));
      }
    } catch (e) {
      translations = {};
      stdout.writeln(
          '  \x1B[33m[WARN]\x1B[0m Could not parse ${p.basename(file.path)}. File might be corrupted or empty. Starting sync from scratch for this file.');
    }

    bool wasModified = false;

    // --- UPDATED: The loop now ignores the special 'ln_name' key ---
    // It only syncs actual translation keys.
    for (final key in _baseTranslations.keys) {
      if (key == 'ln_name') continue; // Do not sync the language name key.

      if (!translations.containsKey(key)) {
        translations[key] = _baseTranslations[key]!;
        wasModified = true;
        stdout.writeln(
            '  \x1B[33m[SYNC]\x1B[0m Added missing key "$key" to ${p.basename(file.path)}');
      }
    }

    if (wasModified) {
      final encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(translations));
    }
  }
}
