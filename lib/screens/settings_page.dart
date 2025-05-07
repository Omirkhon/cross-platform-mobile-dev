import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Center(
              child: Text(
                "SETTINGS",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          const Divider(),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentTheme, _) {
              return ListTile(
                title: Text('Dark mode'),
                trailing: Switch(
                  value: currentTheme == ThemeMode.dark,
                  onChanged: (bool value) {
                    themeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<Locale>(
              value: localeNotifier.value,
              onChanged: (Locale? newValue) {
                if (newValue != null) {
                  localeNotifier.value = newValue;
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('ru'),
                  child: Text('Русский'),
                ),
                DropdownMenuItem(
                  value: Locale('kk'),
                  child: Text('Қазақша'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}