import 'package:flutter/material.dart';

import '../main.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode currentMode = themeNotifier.value;

    return Scaffold(
      appBar: AppBar(title: const Text("Theme Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose Theme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text("Light Mode"),
              trailing: Icon(
                currentMode == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                themeNotifier.value = ThemeMode.light;
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              trailing: Icon(
                currentMode == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                themeNotifier.value = ThemeMode.dark;
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text("System Default"),
              trailing: Icon(
                currentMode == ThemeMode.system
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                themeNotifier.value = ThemeMode.system;
              },
            ),
          ],
        ),
      ),
    );
  }
}
