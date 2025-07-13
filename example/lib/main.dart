import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toln/toln.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ToLn.init(baseLocale: 'en');
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: ToLn.localeNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'toLn Showcase'.toLn(),
          debugShowCheckedModeBanner: false,
          locale: currentLocale,
          builder: (context, navigator) {
            return Directionality(
              textDirection: ToLn.currentDirection,
              child: navigator!,
            );
          },
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.tealAccent,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: const ColorScheme.dark(
              primary: Colors.tealAccent,
              secondary: Colors.amberAccent,
              onPrimary: Colors.black,
            ),
            textTheme: const TextTheme(
              headlineMedium:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
              labelLarge: TextStyle(fontWeight: FontWeight.bold),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.tealAccent),
              ),
            ),
          ),
          // --- THE FINAL FIX IS HERE! ---
          // The 'const' keyword is removed.
          // This tells Flutter to rebuild ShowcasePage when the locale changes.
          home: ShowcasePage(),
        );
      },
    );
  }
}

class ShowcasePage extends StatelessWidget {
  // We also remove the const from here as it's no longer a const widget.
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String username = "Alex";
    const int messageCount = 5;
    const int taskCount = 2;
    final String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Dashboard'.toLn()),
        actions: [
          FutureBuilder<List<LocaleInfo>>(
            future: ToLn.getAvailableLocales(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.translate),
                onSelected: ToLn.loadLocale,
                itemBuilder: (context) => snapshot.data!
                    .map((locale) => PopupMenuItem(
                        value: locale.code, child: Text(locale.name)))
                    .toList(),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Welcome back, $username! The time is $formattedTime.'.toLn(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview'.toLn(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white)),
                  const Divider(height: 20, color: Colors.white24),
                  Text(
                      'You have $messageCount new messages and $taskCount pending tasks.'
                          .toLn()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              labelText: 'Search'.toLn(),
              hintText: 'Enter a keyword...'.toLn(),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(
              3,
              (index) => ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('Item number ${index + 1}'.toLn()),
                    subtitle:
                        Text('This is a description for the item.'.toLn()),
                  )),
        ],
      ),
    );
  }
}
