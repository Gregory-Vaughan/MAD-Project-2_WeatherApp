import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityNotesScreen extends StatelessWidget {
  const CommunityNotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Notes"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('postcards')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading postcards.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final postcards = snapshot.data!.docs;
          if (postcards.isEmpty) {
            return const Center(child: Text('No postcards yet.'));
          }
          return ListView.builder(
            itemCount: postcards.length,
            itemBuilder: (context, index) {
              final data = postcards[index].data() as Map<String, dynamic>;
              final imageBase64 = data['image'] as String?;
              final customText = data['customText'] as String? ?? '';
              final displayName = data['displayName'] as String? ?? 'Anonymous';
              final preferredCity = data['preferredCity'] as String? ?? 'Unknown City';
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? timestamp.toDate()
                  : DateTime.now();

              Uint8List? imageBytes;
              if (imageBase64 != null) {
                try {
                  imageBytes = base64Decode(imageBase64);
                } catch (e) {
                  imageBytes = null;
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageBytes != null)
                        Image.memory(
                          imageBytes,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        customText,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— $displayName from $preferredCity',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.toLocal()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
