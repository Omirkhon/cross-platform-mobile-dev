import 'package:cross_platform_mobile_dev/screens/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final isGuest = auth.isGuest;

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Center(
              child: Text(
                "nav.settings".tr().toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
          if (isGuest)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'guest.warning'.tr(),
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const Divider(),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentTheme, _) {
              return ListTile(
                title: Text('settings.mode'.tr()),
                trailing: Switch(
                  value: currentTheme == ThemeMode.dark,
                  onChanged: isGuest
                      ? null
                      : (bool value) async {
                    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                    await auth.updateUserPreferences(
                      theme: value ? 'dark' : 'light',
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text('settings.language'.tr()),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              onChanged: isGuest
                  ? null
                  : (Locale? newValue) async {
                if (newValue != null) {
                  await context.setLocale(newValue);
                  await auth.updateUserPreferences(
                    language: newValue.languageCode,
                  );
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
          if (!isGuest) ...[
            const Divider(),
            ListTile(
              title: Text('profile.title'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ],
      ),
    );
  }
}
