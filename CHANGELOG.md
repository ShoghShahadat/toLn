
All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog,
and this project adheres to Semantic Versioning.

[0.0.1] - 2025-07-13
✨ Added (ویژگی‌های اضافه شده)
Initial Release of the Revolutionary toLn Library!

Zero-Key Workflow: Completely automated key generation. Developers never need to manage translation keys.

Intelligent CLI Tools: A full suite of command-line tools to manage the localization workflow.

dart run toln extract: A powerful and accurate AST-based extractor for finding all translatable strings.

dart run toln sync: Automatically syncs all translation files with the base file, adding missing keys.

dart run toln auto-apply: The magic command to refactor an entire existing project.

Automatically adds .toLn() to all display strings in supported widgets.

Automatically injects the toln import.

Automatically configures the main() function with async, ensureInitialized, and ToLn.init().

Smart Assistant: Integrated into the extract command to detect typos and similar strings, allowing reuse of existing translations.

Automatic UI Updates: Uses a ValueNotifier (ToLn.localeNotifier) to rebuild the UI instantly on locale change, eliminating the need for manual setState calls.

Automatic Text Direction: ToLn.currentDirection automatically provides the correct TextDirection (LTR/RTL) based on the active language.

Dynamic Language Discovery: The ToLn.getAvailableLocales() method scans the project assets to find all available languages.

Customizable Language Names: Supports an optional ln_name key in translation files for user-friendly display names, with a smart fallback to the language code.