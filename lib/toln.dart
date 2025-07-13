// lib/toln.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode, ValueNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

typedef LocaleInfo = ({String code, String name});

/// A revolutionary localization library that automates the entire translation workflow.
/// Version 5.0 introduces robust fallback for empty display names.
class ToLn {
  static final ToLn _instance = ToLn._internal();
  factory ToLn() => _instance;
  ToLn._internal();

  late final String _baseLocale;
  late String _currentLocale;

  Map<String, String> _baseTranslations = {};
  Map<String, String> _currentTranslations = {};
  Map<String, String> _keyMap = {};

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  TextDirection _currentDirection = TextDirection.ltr;
  final List<String> _rtlLocales = const ['fa', 'ar', 'he', 'ur'];

  static TextDirection get currentDirection => _instance._currentDirection;

  static Future<void> init({
    required String baseLocale,
    String? initialLocale,
  }) async {
    final inst = _instance;
    inst._baseLocale = baseLocale;
    inst._currentLocale = baseLocale;

    try {
      await inst._loadKeyMap();
      inst._baseTranslations = await inst._loadTranslationFile('base');

      String startLocale = initialLocale ??
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      await loadLocale(startLocale);

      if (kDebugMode) {
        print(
            'ToLn Initialized. Base: $baseLocale, Initial: ${inst._currentLocale}. Keys: ${inst._keyMap.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            'ToLn Initialization Error: Could not load base files. Error: $e');
      }
    }
  }

  static Future<void> loadLocale(String newLocale) async {
    final inst = _instance;
    if (inst._currentLocale == newLocale &&
        inst._currentTranslations.isNotEmpty) return;

    try {
      if (newLocale == inst._baseLocale) {
        inst._currentTranslations = Map.from(inst._baseTranslations);
      } else {
        inst._currentTranslations = await inst._loadTranslationFile(newLocale);
      }
      inst._currentLocale = newLocale;
    } catch (e) {
      inst._currentTranslations = Map.from(inst._baseTranslations);
      inst._currentLocale = inst._baseLocale;
      if (kDebugMode) {
        print(
            'ToLn Warning: Could not load locale "$newLocale". Falling back to base locale "${inst._baseLocale}".');
      }
    }

    inst._updateTextDirection();
    localeNotifier.value = Locale(inst._currentLocale);

    if (kDebugMode) {
      print('ToLn Locale changed to: ${inst._currentLocale}');
    }
  }

  /// --- UPDATED IN V5.0: Handles empty ln_name values gracefully ---
  static Future<List<LocaleInfo>> getAvailableLocales() async {
    final List<LocaleInfo> availableLocales = [];
    final inst = _instance;

    try {
      // 1. Handle the base locale first
      final String baseNameValue = inst._baseTranslations['ln_name'] ?? '';
      final baseName = baseNameValue.isNotEmpty
          ? baseNameValue
          : inst._baseLocale.toUpperCase();
      availableLocales.add((code: inst._baseLocale, name: baseName));

      // 2. Scan for other locales
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final localeAssetPaths = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/locales/') && key.endsWith('.ln'))
          .where((path) =>
              !path.endsWith('base.ln') && !path.endsWith('key_map.ln'));

      for (final path in localeAssetPaths) {
        final code = path.split('/').last.replaceAll('.ln', '');
        try {
          final fileContent = await rootBundle.loadString(path);
          final Map<String, dynamic> translations = json.decode(fileContent);

          // --- THE FIX IS HERE! ---
          // Get the ln_name value, defaulting to an empty string if null.
          final String nameValue = translations['ln_name'] as String? ?? '';
          // If the retrieved name is empty, use the capitalized language code instead.
          final name = nameValue.isNotEmpty ? nameValue : code.toUpperCase();

          availableLocales.add((code: code, name: name));
        } catch (e) {
          availableLocales.add((code: code, name: code.toUpperCase()));
        }
      }
      return availableLocales;
    } catch (e) {
      if (kDebugMode) {
        print(
            'ToLn Error: Could not read AssetManifest.json to find locales. $e');
      }
      return availableLocales.isEmpty
          ? [(code: inst._baseLocale, name: inst._baseLocale.toUpperCase())]
          : availableLocales;
    }
  }

  void _updateTextDirection() {
    _currentDirection = _rtlLocales.contains(_currentLocale)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Future<void> _loadKeyMap() async {
    final path = 'assets/locales/key_map.ln';
    final jsonString = await rootBundle.loadString(path);
    _keyMap = Map<String, String>.from(json.decode(jsonString));
  }

  Future<Map<String, String>> _loadTranslationFile(String fileName) async {
    final path = 'assets/locales/$fileName.ln';
    final jsonString = await rootBundle.loadString(path);
    return Map<String, String>.from(json.decode(jsonString));
  }

  String _translate(String text, {String? manualKey}) {
    if (manualKey != null) {
      return _currentTranslations[manualKey] ??
          _baseTranslations[manualKey] ??
          manualKey;
    }
    if (_keyMap.containsKey(text)) {
      final key = _keyMap[text]!;
      return _currentTranslations[key] ?? _baseTranslations[key] ?? key;
    }
    for (final template in _keyMap.keys) {
      if (!template.contains(r'$s')) continue;
      try {
        const placeholder = '___TOLN_PLACEHOLDER___';
        final templateWithPlaceholder = template.replaceAll(r'$s', placeholder);
        final escapedTemplate = templateWithPlaceholder.replaceAllMapped(
            RegExp(r'[.*+?^${}()|[\]\\]'), (match) => '\\${match.group(0)}');
        final regexPattern =
            '^${escapedTemplate.replaceAll(placeholder, '(.*?)')}\$';
        final regex = RegExp(regexPattern, dotAll: true);
        final match = regex.firstMatch(text);
        if (match != null) {
          final key = _keyMap[template]!;
          final translatedTemplate =
              _currentTranslations[key] ?? _baseTranslations[key] ?? key;
          final variables = <String>[];
          for (int i = 1; i <= match.groupCount; i++) {
            variables.add(match.group(i)!);
          }
          String result = translatedTemplate;
          for (final variable in variables) {
            result = result.replaceFirst(r'$s', variable);
          }
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          print(
              'ToLn Internal Error: Failed to process template "$template". Error: $e');
        }
        continue;
      }
    }
    if (kDebugMode) {
      print('ToLn Warning: No key found for text: "$text"');
    }
    return text;
  }
}

extension ToLnExtension on String {
  String toLn({String? key}) {
    return ToLn()._translate(this, manualKey: key);
  }
}
