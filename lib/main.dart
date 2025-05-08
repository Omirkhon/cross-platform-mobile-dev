import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/about_page2.dart';
import 'screens/main_page.dart';
import 'screens/settings_page.dart';
import 'screens/profile_page.dart';
import 'screens/login_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
ValueNotifier<Locale> localeNotifier = ValueNotifier(Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyAz-K4g5czNxzq0NW23xlS6yNLiV4Q0wTQ",
        authDomain: "fir-flutter-32a56.firebaseapp.com",
        projectId: "fir-flutter-32a56",
        storageBucket: "fir-flutter-32a56.firebasestorage.app",
        messagingSenderId: "30939901282",
        appId: "1:30939901282:web:dbae53f514eca15994d03b"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _auth = AuthService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, selectedLocale, _) {
            return StreamBuilder<User?>(
              stream: _auth.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final user = snapshot.data;
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
                    locale: selectedLocale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    initialRoute: '/',
                    routes: {
                      '/': (context) => user == null ? const LoginPage() : const MyHomePage(),
                      '/about2': (context) => const AboutPage2(),
                      '/settings': (context) => const SettingsPage(),
                      '/profile': (context) => const ProfilePage(),
                      '/login': (context) => const LoginPage(),
                    },
                  );
                }
                return const MaterialApp(
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            );
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
  final AuthService _auth = AuthService();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isGuest = user == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
        ],
      ),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          if (!isGuest)
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
        ],
      ),
    );
  }
}