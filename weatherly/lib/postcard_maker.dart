/*
import 'package:flutter/material.dart';

class PostcardMakerScreen extends StatefulWidget {
  const PostcardMakerScreen({super.key});

  @override
  State<PostcardMakerScreen> createState() => _PostcardMakerScreenState();
}

class _PostcardMakerScreenState extends State<PostcardMakerScreen> {
  String selectedEmoji = "☀️";
  Color backgroundColor = Colors.blue[100]!;
  final messageController = TextEditingController();

  final List<String> emojis = ["☀️", "🌧️", "❄️", "⛈️", "🌫️", "🌈"];
  final List<Color> bgColors = [
    Colors.blue[100]!,
    Colors.orange[100]!,
    Colors.purple[100]!,
    Colors.green[100]!,
    Colors.grey[300]!,
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Postcard Maker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Create a Weather Postcard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Postcard preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(selectedEmoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    messageController.text.isNotEmpty
                        ? messageController.text
                        : "Your message here",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Message input
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: "Message",
                hintText: "Enter a custom message...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Emoji picker
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji = emoji;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: emoji == selectedEmoji
                            ? Colors.blue[300]
                            : Colors.grey[200],
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Background color picker
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: bgColors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final color = bgColors[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        backgroundColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: color == backgroundColor
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Postcard saved!")),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text("Save Postcard"),
            ),
          ],
        ),
      ),
    );
  }
}

*/