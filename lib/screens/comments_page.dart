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
  User? _currentUser;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();
  final _commentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }
  Future<void> _submitComment() async {
    if (_currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in. Cannot post.")),
        );
      }
      return;
    }

    if (mounted) {
      setState(() { _isLoading = true; });
    }

    try {
      String username = _currentUser!.displayName ?? "Anonymous";
      DocumentSnapshot userData = await _firestoreService.getUserData(_currentUser!.uid);
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        if (data.containsKey('username') && data['username'] != null && (data['username'] as String).isNotEmpty) {
          username = data['username'];
        }
      }

      await _firestoreService.createComment(
        userId: _currentUser!.uid,
        username: username,
        postId: widget.postId,
        commentText: _commentController.text.trim(),
        userImageUrl: _currentUser!.photoURL ?? "https://via.placeholder.com/150?text=No+Image",
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Comment created successfully!"),
          duration: Duration(seconds: 1),
          ),
      );
      setState(() {
        _commentController.clear();
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving comment: $e")),
      );
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        color: Colors.grey[900],
        height: 500,
        child: Column(
          children: [
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(width: 100, height: 5, color: Colors.white),
            ),
            const SizedBox(height: 5),
            const Text(
              "Comments",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('postId', isEqualTo: widget.postId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    padding: const EdgeInsets.only(bottom: 10),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> commentData =
                          comments[index].data() as Map<String, dynamic>;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (commentData['userImageUrl'] ?? "https://via.placeholder.com/150?text=No+Image") as String,
                          ),
                        ),
                        title: Text(
                          (commentData['username'] ?? "Unknown") as String,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          (commentData['text'] ?? "") as String,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
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
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        _submitComment();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Comment cannot be empty.")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

