import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_pbb_kel6/screens/edit_post_page.dart';
import 'package:fp_pbb_kel6/screens/comments_page.dart';

class DetailPost extends StatelessWidget {
  final String? initialPostId;
  const DetailPost({super.key, this.initialPostId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts found.'));
          }
          var posts = snapshot.data!.docs;
          if (initialPostId != null) {
            final idx = posts.indexWhere((doc) => doc.id == initialPostId);
            if (idx > 0) {
              final first = posts[idx];
              posts = [first, ...posts.where((doc) => doc.id != initialPostId)];
            }
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final postData = posts[index].data() as Map<String, dynamic>;
              final username = postData['username'] as String? ?? 'Unknown user';
              final caption = postData['caption'] as String? ?? 'No caption';
              final imageUrl = postData['imageUrl'] as String? ?? '';
              final postId = posts[index].id;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final postOwnerId = postData['userId'] as String?;
                              final currentUser = FirebaseAuth.instance.currentUser;
                              if (currentUser != null && postOwnerId == currentUser.uid) {
                                return PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPostPage(
                                            postId: postId,
                                            postData: postData,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      await FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(postId)
                                          .delete();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                    if (imageUrl.isNotEmpty && imageUrl != 'https://via.placeholder.com/150?text=No+Image')
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                      )
                    else
                      Container(
                        height: 300,
                        color: Colors.grey[900],
                        child: const Center(child: Icon(Icons.broken_image, size: 100)),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement like
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  child: DraggableScrollableSheet(
                                    maxChildSize: 1,
                                    initialChildSize: 1,
                                    minChildSize: 0.2,
                                    builder: (context, scrollController) {
                                      return CommentsPage(postId: postId);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .where('postId', isEqualTo: postId)
                              .snapshots(),
                          builder: (context, commentSnapshot) {
                            int count = commentSnapshot.hasData ? commentSnapshot.data!.docs.length : 0;
                            return Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  '$username ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: caption,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('comments')
                          .where('postId', isEqualTo: postId)
                          .orderBy('timestamp', descending: false)
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        int commentCount = commentSnapshot.data!.docs.length;
                        final comments = commentSnapshot.data!.docs.take(2);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...comments.map((comment) {
                                final commentData = comment.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0, left: 20.0),
                                  child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.baseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                              '${commentData['username']} ',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: commentData['text'],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (commentCount > 2)
                                GestureDetector(
                                  onTap: () {
                                    showBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context).viewInsets.bottom,
                                          ),
                                          child: DraggableScrollableSheet(
                                            maxChildSize: 1,
                                            initialChildSize: 1,
                                            minChildSize: 0.2,
                                            builder: (context, scrollController) {
                                              return CommentsPage(postId: postId);
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0, bottom: 4.0),
                                    child: Text(
                                      'View all $commentCount comments',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
