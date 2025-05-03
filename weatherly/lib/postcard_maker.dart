import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  Future<void> savePostcard() async {
    try {
      setState(() => isSaving = true);

      final Uint8List? imageBytes = await screenshotController.capture();

      if (imageBytes == null) throw Exception("Failed to capture image.");

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/postcard_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      final ref = FirebaseStorage.instance
          .ref()
          .child('postcards')
          .child('postcard_${DateTime.now().millisecondsSinceEpoch}.png');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved and uploaded! URL:\n$url')),
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
              onPressed: isSaving ? null : savePostcard,
              icon: const Icon(Icons.save),
              label: Text(isSaving ? 'Saving...' : 'Save Postcard'),
            ),
          ],
        ),
      ),
    );
  }
}
