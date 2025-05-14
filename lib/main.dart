import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/about_page2.dart';
import 'screens/main_page.dart';
import 'screens/settings_page.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
      path: 'assets/translation',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'To-Do List',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[100],
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[900],
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeMode,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          initialRoute: '/',
          routes: {
            '/': (context) => const MyHomePage(),
            '/about2': (context) => const AboutPage2(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const <Widget>[
          MainPage(),
          AboutPage2(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: tr('nav.home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: tr('nav.about'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: tr('nav.settings'),
          ),
        ],
      ),
    );
  }
}
