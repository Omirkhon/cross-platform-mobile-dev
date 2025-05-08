import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(
                'Logged in as:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                user.email ?? 'No email',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
            ],
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentTheme, _) {
                return ListTile(
                  title: const Text('Dark Mode'),
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
            const Divider(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await auth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}