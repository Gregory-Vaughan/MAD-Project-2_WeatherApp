import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; // Ensure LoginScreen is accessible here

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final cityController = TextEditingController();

  String savedCity = '';
  bool isEditingAccount = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = user?.displayName ?? '';
    _loadCity();
  }

  Future<void> _loadCity() async {
    final uid = user?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final city = doc.data()?['city'] ?? '';

    setState(() {
      savedCity = city;
      cityController.text = city;
    });
  }

  Future<void> _saveCity() async {
    final uid = user?.uid;
    if (uid == null) return;

    final city = cityController.text.trim();
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'city': city,
    }, SetOptions(merge: true));

    setState(() => savedCity = city);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("City saved successfully")),
    );
  }

  Future<void> updateAccountInfo() async {
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final currentPassword = currentPasswordController.text.trim();

    if (password.isNotEmpty && currentPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your current password to change password.")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      if (password.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: user!.email!,
          password: currentPassword,
        );
        await user!.reauthenticateWithCredential(credential);
        await user!.updatePassword(password);
      }

      if (name.isNotEmpty && name != user!.displayName) {
        await user!.updateDisplayName(name);
      }

      await user!.reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account updated successfully")),
      );

      setState(() => isEditingAccount = false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? "User";
    final email = user?.email ?? "email@example.com";

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.blueAccent),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Back to Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionHeader("Preferences"),
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text("Edit Account Info"),
                        subtitle: const Text("Display Name or Password"),
                        trailing: Icon(isEditingAccount ? Icons.close : Icons.arrow_forward_ios),
                        onTap: () {
                          setState(() => isEditingAccount = !isEditingAccount);
                        },
                      ),
                      if (isEditingAccount)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(labelText: "Display Name"),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(labelText: "New Password"),
                                obscureText: true,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: currentPasswordController,
                                decoration: const InputDecoration(labelText: "Current Password"),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      onPressed: updateAccountInfo,
                                      child: const Text("Update Account"),
                                    ),
                            ],
                          ),
                        ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.location_city),
                        title: const Text("Default City"),
                        subtitle: Text(savedCity.isNotEmpty ? savedCity : "Not set"),
                        trailing: const Icon(Icons.edit_location_alt),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Set Default City"),
                              content: TextField(
                                controller: cityController,
                                decoration: const InputDecoration(
                                  hintText: "Enter city name",
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _saveCity();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionHeader("Account"),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text("Logout"),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
