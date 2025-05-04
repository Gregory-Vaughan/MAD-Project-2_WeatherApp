import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostcardMakerScreen extends StatefulWidget {
  const PostcardMakerScreen({Key? key}) : super(key: key);

  @override
  State<PostcardMakerScreen> createState() => _PostcardMakerScreenState();
}

class _PostcardMakerScreenState extends State<PostcardMakerScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  String customText = 'Greetings from Weatherly!';
  Color backgroundColor = Colors.blueAccent;
  bool isSaving = false;

  Future<void> savePostcardToFirestore() async {
    try {
      setState(() => isSaving = true);

      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes == null) throw Exception("Failed to capture image.");

      final String base64Image = base64Encode(imageBytes);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No authenticated user.");

      final uid = user.uid;
      final displayName = user.displayName ?? "Anonymous";

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final city = userDoc.data()?['city'] ?? "Unknown";

      await FirebaseFirestore.instance.collection('postcards').add({
        'image': base64Image,
        'customText': customText,
        'timestamp': FieldValue.serverTimestamp(),
        'displayName': displayName,
        'city': city,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postcard saved to Firestore!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postcard Maker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Container(
                height: 200,
                width: double.infinity,
                color: backgroundColor,
                alignment: Alignment.center,
                child: Text(
                  customText,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Custom Text'),
              onChanged: (value) => setState(() => customText = value),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Background:'),
                DropdownButton<Color>(
                  value: backgroundColor,
                  onChanged: (Color? newColor) {
                    if (newColor != null) {
                      setState(() => backgroundColor = newColor);
                    }
                  },
                  items: [
                    Colors.blueAccent,
                    Colors.green,
                    Colors.orange,
                    Colors.purple
                  ].map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Container(
                        width: 50,
                        height: 20,
                        color: color,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isSaving ? null : savePostcardToFirestore,
              icon: const Icon(Icons.save),
              label: Text(isSaving ? 'Saving...' : 'Save Postcard'),
            ),
          ],
        ),
      ),
    );
  }
}
