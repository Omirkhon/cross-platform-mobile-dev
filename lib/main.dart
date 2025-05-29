import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/about_page2.dart';
import 'screens/main_page.dart';
import 'screens/settings_page.dart';
import 'screens/auth_page.dart';
import 'screens/profile_page.dart';
import 'screens/guest_home_page.dart';
import 'screens/connectivity_service.dart';
import 'screens/auth_service.dart';
import 'screens/sync_banner.dart';
import 'screens/history_page.dart';
import 'screens/notification_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    
    await Hive.initFlutter();
    await Hive.openBox('localStorage');
    await Hive.openBox('preferences');

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
    await NotificationService.init();
    await EasyLocalization.ensureInitialized();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
        path: 'assets/translation',
        fallbackLocale: const Locale('en'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthService(context)),
            ChangeNotifierProvider(create: (_) => ConnectivityService()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    debugPrint("Initialization error: $e");
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
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
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
          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const AuthPage(),
            '/home': (context) => const MyHomePage(),
            '/guest': (context) => const GuestHomePage(),
            '/about': (context) => const AboutPage2(),
            '/history': (context) => const HistoryPage(),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isGuest = auth.isGuest;
    final isOffline = context.watch<ConnectivityService>().isOffline;
    final localeKey = context.locale.toString();
    

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: 'nav.home'.tr(),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.info),
        label: 'nav.about'.tr(),
      ),
      if (!isGuest) ...[
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: 'nav.history'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'nav.settings'.tr(),
        ),
      ],
    ];

    return KeyedSubtree(
      key: ValueKey(localeKey),
      child: Scaffold(
        body: Column(
          children: [
            if (!isGuest) const SyncBanner(), 
            if (isOffline)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.all(12),
                child: Text(
                  'offline_mode'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  const MainPage(),
                  const AboutPage2(),
                  if (!isGuest) const HistoryPage() else Container(),
                  if (!isGuest) const SettingsPage() else Container(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex.clamp(0, navItems.length - 1),
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: navItems,
          onTap: (index) {
            if (isGuest && index >= 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('guest_restriction'.tr())),
              );
              return;
            }
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}