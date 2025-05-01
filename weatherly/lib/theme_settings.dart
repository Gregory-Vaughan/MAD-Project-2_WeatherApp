/*
import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Theme Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Choose Theme",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.light_mode),
              title: Text("Light Mode"),
              trailing: Icon(Icons.radio_button_unchecked),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text("Dark Mode"),
              trailing: Icon(Icons.radio_button_unchecked),
            ),
            ListTile(
              leading: Icon(Icons.brightness_auto),
              title: Text("System Default"),
              trailing: Icon(Icons.radio_button_checked),
            ),
          ],
        ),
      ),
    );
  }
}

*/