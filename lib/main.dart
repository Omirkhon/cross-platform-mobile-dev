import 'package:cross_platform_mobile_dev/screens/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'screens/about_page2.dart';
import 'screens/main_page.dart';
import 'screens/settings_page.dart';
import 'screens/auth_page.dart';
import 'screens/profile_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAz-K4g5czNxzq0NW23xlS6yNLiV4Q0wTQ",
          authDomain: "fir-flutter-32a56.firebaseapp.com",
          projectId: "fir-flutter-32a56",
          storageBucket: "fir-flutter-32a56.appspot.com",
          messagingSenderId: "30939901282",
          appId: "1:30939901282:web:dbae53f514eca15994d03b",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    await EasyLocalization.ensureInitialized();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
        path: 'assets/translation',
        fallbackLocale: const Locale('en'),
        child: ChangeNotifierProvider(
          create: (context) => AuthService(),
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }
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
          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const AuthPage(),
            '/home': (context) => const MyHomePage(),
            '/about': (context) => const AboutPage2(),
            '/settings': (context) => const SettingsPage(),
            '/profile': (context) => ProfilePage(auth: Provider.of<AuthService>(context)),
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
    final auth = Provider.of<AuthService>(context, listen: false);
    if (index == 3 && auth.isGuest) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isGuest = auth.isGuest;

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
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'nav.home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: 'nav.about'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'nav.settings'.tr(),
          ),
          if (!isGuest)
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'nav.profile'.tr(),
            )
          else
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              label: 'nav.guest'.tr(),
            ),
        ],
      ),
    );
  }
}