import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPost extends StatelessWidget {
  final String imageUrl;
  const DetailPost({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .where('imageUrl', isEqualTo: imageUrl)
            .limit(1)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Post not found.'));
          }
          final postData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final username = postData['username'] as String? ?? 'Unknown user';
          final caption = postData['caption'] as String? ?? '';
          final postId = snapshot.data!.docs.first.id;
          final likes = postData['likes'] as int? ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(caption),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('$likes likes'),
                ],
              ),
              const Divider(height: 32),
              const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('postId', isEqualTo: postId)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, commentSnapshot) {
                  if (commentSnapshot.hasError) {
                    return const Text('Failed to load comments');
                  }
                  if (commentSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                    return const Text('No comments yet.');
                  }
                  final comments = commentSnapshot.data!.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: comments.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final commentUser = data['username'] ?? 'User';
                      final commentText = data['text'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: '$commentUser ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: commentText),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
