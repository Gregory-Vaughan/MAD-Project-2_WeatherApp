//screen name should probably be changed

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "John Doe",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("johndoe@example.com", style: TextStyle(fontSize: 16)),

            const Divider(height: 32),

            ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text("Temperature Units"),
              subtitle: const Text("Celsius"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Open temperature unit selector
              },
            ),

            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("App Theme"),
              subtitle: const Text("Light"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Open theme selector
              },
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () {
                // Add logout or navigation functionality here
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            )
          ],
        ),
      ),
    );
  }
}

