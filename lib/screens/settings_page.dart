import 'package:flutter/material.dart';
import '../main.dart';
import 'package:easy_localization/easy_localization.dart';

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
                tr("nav.settings").toUpperCase(),
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
                title: Text(tr('settings.mode')),
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
            title: Text(tr('settings.language')),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              onChanged: (Locale? newValue) async {
                if (newValue != null) {
                  await context.setLocale(newValue);
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