<p align="center">
  <img src="https://user-images.githubusercontent.com/28951144/234489717-P-O-L-N-O-S-T-Ь-Ю-A-V-T-O-M-A-T-I-Ч-Е-С-К-А-Я-L-O-K-A-L-I-Z-A-Ц-И-Я.gif" alt="toLn Showcase GIF" width="600">
</p>

<h1 align="center">toLn: The Revolutionary Flutter Localization Library</h1>

<p align="center">
  <strong>Forget keys. Forget manual setup. Just write your code.</strong>
</p>
<p align="center">
  <a href="https://github.com/ShoghShahadat/toLn/Fa.md">[نسخه فارسی]</a>
</p>
<p align="center">
  <a href="https://pub.dev/packages/toln"><img src="https://img.shields.io/pub/v/toln.svg?style=for-the-badge&logo=dart" alt="Pub Version"></a>
  <a href="https://github.com/your_username/toln/blob/main/LICENSE"><img src="https://img.shields.io/github/license/your_username/toln.svg?style=for-the-badge" alt="License"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/platform-flutter-02569B.svg?style=for-the-badge&logo=flutter" alt="Platform"></a>
  <a href="https://github.com/your_username/toln/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge" alt="PRs Welcome"></a>
</p>

---

**toLn** is not just another localization library; it's a complete paradigm shift. We've built an intelligent assistant that handles the entire tedious internationalization workflow, letting you focus on what truly matters: building amazing applications.

## Table of Contents
- [Table of Contents](#table-of-contents)
- [🚀 The Revolution: What Makes `toLn` Different?](#-the-revolution-what-makes-toln-different)
- [✨ Core Features at a Glance](#-core-features-at-a-glance)
- [🛠️ A Practical Walkthrough: Localizing an App in 5 Minutes](#️-a-practical-walkthrough-localizing-an-app-in-5-minutes)
  - [Step 1: The Unlocalized App](#step-1-the-unlocalized-app)
  - [Step 2: The Magic `auto-apply` Command](#step-2-the-magic-auto-apply-command)
  - [Step 3: The Generated Files](#step-3-the-generated-files)
  - [Step 4: Translating](#step-4-translating)
  - [Step 5: Making it Interactive](#step-5-making-it-interactive)
- [⚙️ The `toLn` Workflow](#️-the-toln-workflow)
- [📚 Deep Dive: API \& CLI Reference](#-deep-dive-api--cli-reference)
  - [The `ToLn` Class](#the-toln-class)
    - [`static Future<void> init({required String baseLocale, String? initialLocale})`](#static-futurevoid-initrequired-string-baselocale-string-initiallocale)
    - [`static Future<void> loadLocale(String newLocale)`](#static-futurevoid-loadlocalestring-newlocale)
    - [`static Future<List<LocaleInfo>> getAvailableLocales()`](#static-futurelistlocaleinfo-getavailablelocales)
    - [`static TextDirection get currentDirection`](#static-textdirection-get-currentdirection)
    - [`static final ValueNotifier<Locale> localeNotifier`](#static-final-valuenotifierlocale-localenotifier)
  - [The `.toLn()` Extension Method](#the-toln-extension-method)
    - [`String toLn({String? key})`](#string-tolnstring-key)
  - [The Command-Line Interface (CLI)](#the-command-line-interface-cli)
    - [`dart run toln auto-apply`](#dart-run-toln-auto-apply)
    - [`dart run toln extract`](#dart-run-toln-extract)
    - [`dart run toln sync`](#dart-run-toln-sync)
- [⚠️ The `const` Trap: A Crucial Note](#️-the-const-trap-a-crucial-note)
- [💖 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🚀 The Revolution: What Makes `toLn` Different?

Traditional localization is a nightmare of key management, manual file updates, and constant human error. **`toLn` eliminates all of it.** We believe your code should be the single source of truth.

| Feature                  | The Old Way (The Pain)                                                              | The `toLn` Way (The Magic)                                                                       |
| :----------------------- | :---------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------- |
| **Adding New Text** | 1. Invent a key. 2. Open `en.json`. 3. Add the key. 4. Open `fa.json`. 5. Add it again... | Write `Text('Hello World'.toLn())`. **That's it.** |
| **Refactoring a Project**| Impossible. You have to manually add localization to every string.                  | `dart run toln auto-apply`. The library intelligently refactors your entire codebase for you.    |
| **Fixing a Typo** | Find the key, update it in all translation files, hope you didn't miss one.         | Just fix the text in your code. Our **Smart Assistant** detects it and offers to reuse the old key. |
| **Syncing Translations** | Manually compare JSON files to find what's missing.                                 | `dart run toln sync`. All missing keys are added to your translation files automatically.        |
| **Updating the UI** | Use `setState` or complex state management solutions to trigger a rebuild.          | **Fully Automatic.** The UI rebuilds itself instantly when the language changes.                 |

## ✨ Core Features at a Glance

-   ✅ **Zero-Key Workflow**: You will never have to invent or manage a translation key again.
-   🪄 **Intelligent `auto-apply`**: Automatically refactors your existing unlocalized project to use `toLn` with a single command.
-   🧠 **Smart Assistant**: Detects typos and corrections, suggesting to reuse existing translations to save you work.
-   🔄 **Automatic UI Updates**: The UI instantly updates on locale change with zero manual `setState` calls, powered by `ValueNotifier`.
-   🌍 **Automatic Text Direction**: Switches between LTR and RTL layouts automatically based on the current language.
-   ⚙️ **Fully Automated CLI**: A powerful command-line interface to `extract`, `sync`, and `auto-apply` translations.
-   🌐 **Dynamic Language Discovery**: Automatically finds all available languages in your project to build language selection menus effortlessly.
-   💅 **Customizable Language Names**: Use the optional `ln_name` key in your files to give languages beautiful display names (e.g., "فارسی" instead of "FA").

---

## 🛠️ A Practical Walkthrough: Localizing an App in 5 Minutes

Let's take a real-world app and make it multilingual.

### Step 1: The Unlocalized App

Imagine you have this simple Flutter page. It's written in English and has no localization.

```dart
// lib/main.dart (Before toLn)
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final String username = "Maria";
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: Text("Welcome, ${username}!"),
      ),
    );
  }
}
```

### Step 2: The Magic `auto-apply` Command

Open your terminal in the project root and run the single magic command:

```bash
dart run toln auto-apply
```

### Step 3: The Generated Files

`toLn` has now performed several actions:
1.  **Modified your code**: It added `.toLn()`, `import`, and the `ToLn.init()` call.
2.  **Ran `extract`**: It scanned the modified code and created files in `assets/locales/`.

Your `main.dart` now looks like this:

```dart
// lib/main.dart (After toLn)
import 'package:flutter/material.dart';
import 'package:toln/toln.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ToLn.init(baseLocale: 'en'); // 'en' is the language of your code
  runApp(const MyApp());
}
// ... (MyApp is now wrapped in a ValueListenableBuilder)
class MyHomePage extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final String username = "Maria";
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page".toLn()),
      ),
      body: Center(
        child: Text("Welcome, ${username}!".toLn()),
      ),
    );
  }
}
```

And your `assets/locales/base.ln` file has been created:

```json
{
  "ln_name": "",
  "keLn1": "My App",
  "keLn2": "Home Page",
  "keLn3": "Welcome, $s!"
}
```

### Step 4: Translating

1.  Copy `base.ln` and rename it to `es.ln` for Spanish.
2.  Fill in the translations and the display name.

```json
// assets/locales/es.ln
{
  "ln_name": "Español",
  "keLn1": "Mi Aplicación",
  "keLn2": "Página de Inicio",
  "keLn3": "¡Bienvenida, $s!"
}
```

### Step 5: Making it Interactive

Now, let's add a language switcher to the `AppBar`. `toLn` makes this incredibly easy.

```dart
// In your MyHomePage build method, inside the AppBar
actions: [
  FutureBuilder<List<LocaleInfo>>(
    future: ToLn.getAvailableLocales(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox();
      return PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        onSelected: ToLn.loadLocale, // Magic! No setState needed.
        itemBuilder: (context) => snapshot.data!
            .map((locale) => PopupMenuItem(value: locale.code, child: Text(locale.name)))
            .toList(),
      );
    },
  ),
],
```
That's it! You now have a fully localized app with an automatic UI and a dynamic language menu.

---

## ⚙️ The `toLn` Workflow

`toLn` is designed to be a complete workflow, not just a library.

1.  **`dart run toln auto-apply`**: Run this once on your project to make it localization-ready. It will automatically run `extract` for you afterwards.
2.  **`dart run toln extract`**: Run this whenever you add or change texts in your UI to update your `base.ln` file.
3.  **`dart run toln sync`**: Run this after `extract` to add the new keys to all your other language files (`fa.ln`, `de.ln`, etc.), ready for translation.

---

## 📚 Deep Dive: API & CLI Reference

Here is a detailed breakdown of every component of the `toLn` ecosystem.

### The `ToLn` Class

This is the main class that manages the localization state.

#### `static Future<void> init({required String baseLocale, String? initialLocale})`
The most important method. It sets up the entire library.
-   **`baseLocale`**: (Required) The language code of the text in your source code (e.g., 'en', 'fa').
-   **`initialLocale`**: (Optional) The language to load at startup. If not provided, `toLn` will intelligently try to use the device's system language. If the system language isn't available, it falls back to your `baseLocale`.

#### `static Future<void> loadLocale(String newLocale)`
Changes the app's current language.
-   **`newLocale`**: The language code to switch to (e.g., 'fa', 'de').
-   **How it works**: This method loads the corresponding `.ln` file, updates the text direction, and notifies all listeners via `ToLn.localeNotifier` to trigger an automatic UI rebuild.

#### `static Future<List<LocaleInfo>> getAvailableLocales()`
Automatically scans your `assets/locales/` directory and returns a list of all available languages.
-   **Returns**: A `List` of `LocaleInfo` objects. `LocaleInfo` is a record defined as `({String code, String name})`.
-   **`code`**: The language code from the filename (e.g., 'en').
-   **`name`**: The display name from the `ln_name` key inside the file. If `ln_name` is missing or empty, it defaults to the capitalized language code (e.g., 'EN').

#### `static TextDirection get currentDirection`
A static getter that returns the correct `TextDirection` (`TextDirection.rtl` or `TextDirection.ltr`) for the currently active locale.

#### `static final ValueNotifier<Locale> localeNotifier`
The engine behind automatic UI updates. You can wrap your `MaterialApp` (or any part of your UI) in a `ValueListenableBuilder` listening to this notifier. When `loadLocale` is called, this notifier fires, and your UI rebuilds with the new translations.

### The `.toLn()` Extension Method

This is the method you will use most often.

#### `String toLn({String? key})`
-   **How it works**: When called on a `String`, it uses the `ToLn` singleton to find the correct translation for the current language. It intelligently handles strings with and without variables.
-   **`key`**: (Optional) A manual key (e.g., 'keLn5'). This is for the rare case where you want two different source texts to point to the same translation key.

### The Command-Line Interface (CLI)

The CLI is your intelligent assistant for managing translation files.

#### `dart run toln auto-apply`
The most powerful command. It analyzes your entire project and intelligently refactors it for localization.
-   **What it does**:
    1.  Adds `.toLn()` to string literals inside common display widgets (`Text`, `Tooltip`, etc.) and `InputDecoration` properties.
    2.  Automatically adds `import 'package:toln/toln.dart';` to any file it modifies.
    3.  Checks your `main()` function and ensures it is `async` and contains `WidgetsFlutterBinding.ensureInitialized()` and `ToLn.init()`.
    4.  After it finishes, it **automatically runs the `extract` command** to generate your translation files.
-   **Options**:
    -   `--dry-run`: Shows a report of what would be changed without actually modifying any files.

#### `dart run toln extract`
Scans your project for all `.toLn()` calls and generates/updates the `base.ln` and `key_map.ln` files.
-   **Smart Assistant**: If it finds a new string that is very similar to an existing one (e.g., you fixed a typo), it will ask you if you want to reuse the old key, saving your existing translations.

#### `dart run toln sync`
Synchronizes all your translation files (`fa.ln`, `de.ln`, etc.) with your master `base.ln` file.
-   **What it does**: It finds any keys that exist in `base.ln` but are missing in your other language files and adds them. The value will be the original text from `base.ln`, making it easy for you or your translator to find and translate new texts.

---

## ⚠️ The `const` Trap: A Crucial Note

**Problem:** My language changes, but the text on the screen doesn't!

This is almost always caused by the `const` keyword. When you declare a widget as `const`, you are telling Flutter: "This widget is immutable and will **never** need to be rebuilt."

When `toLn` changes the language, it needs to rebuild your UI. If it encounters a `const` widget in its path, it stops, and your old text remains.

**Incorrect:**
```dart
// This will NOT update when the language changes!
home: const MyAwesomePage(),
```

**Correct:**
```dart
// Now Flutter is allowed to rebuild the page.
home: MyAwesomePage(),
```

**Rule of thumb: If a widget or any of its children contains text that needs to be translated, do not use `const` on it or its parents in the build method.**

## 💖 Contributing

We have built `toLn` to be a game-changer, but we are just getting started. Contributions, issues, and feature requests are welcome! Feel free to check our [issues page](https://github.com/your_username/toln/issues).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
#   t o L n 
 
 