import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_pbb_kel6/services/firestore_service.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final comment = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.grey[900],
        height: 500,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 155,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  3,
                ), // Adjust the radius as needel
                child: Container(width: 100, height: 5, color: Colors.white),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('comments')
                      .where('postId', isEqualTo: widget.postId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: ( BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot,) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong: [${snapshot.error}]'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No comments yet!"));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 70),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> commentData =
                        comments[index].data() as Map<String, dynamic>;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage( commentData['userImageUrl'],),
                      ),
                      title: Text(commentData['username']),
                      subtitle: Text(commentData['text']),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 60),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.grey[900],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "https://picsum.photos/200/200",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          controller: comment,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

