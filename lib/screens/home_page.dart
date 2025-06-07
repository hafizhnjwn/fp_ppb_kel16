import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/screens/comments_page.dart';
import 'package:fp_pbb_kel6/screens/edit_post_page.dart';
import 'package:fp_pbb_kel6/screens/nav_page.dart';
import 'package:fp_pbb_kel6/screens/user_page.dart';
import 'package:fp_pbb_kel6/services/firestore_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userSnaphot});
  final AsyncSnapshot<User?> userSnaphot;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = widget.userSnaphot.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Instagram Feed",
          style: TextStyle(fontFamily: "Instagram Headline", fontSize: 28),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: [${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet!"));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> postData =
                  posts[index].data() as Map<String, dynamic>;

              String imageUrl =
                  postData['imageUrl'] as String? ??
                  'https://via.placeholder.com/150?text=No+Image';
              String caption = postData['caption'] as String? ?? 'No caption';
              String username =
                  postData['username'] as String? ?? 'Unknown user';

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: SizedBox(
                        height: 32, // Fixed height container
                        child: Row(
                          children: [
                            // Profile Photo
                            GestureDetector(
                              onTap: () {
                                if (postData['userId'] == currentUser?.uid) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const NavigationPage(initialIndex: 2),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserPage(userID: postData['userId']),
                                    ),
                                  );
                                }
                              },
                              child: StreamBuilder<String>(
                                stream: _firestoreService.getUserProfilePhotoUrl(postData['userId']),
                                builder: (context, snapshot) {
                                  return CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      snapshot.data ?? 'https://via.placeholder.com/32?text=No+Image',
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Username
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (postData['userId'] == currentUser?.uid) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const NavigationPage(initialIndex: 2),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserPage(userID: postData['userId']),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  username,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Menu Button Area
                            SizedBox(
                              width: 40,
                              height: 32, // Match parent height
                              child: Builder(
                                builder: (context) {
                                  final postOwnerId = postData['userId'] as String?;
                                  final currentUser = FirebaseAuth.instance.currentUser;
                                  if (currentUser != null && postOwnerId == currentUser.uid) {
                                    return PopupMenuButton<String>(
                                      padding: EdgeInsets.zero, // Remove internal padding
                                      icon: const Icon(Icons.more_vert, color: Colors.white),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditPostPage(
                                                postId: posts[index].id,
                                                postData: postData,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(posts[index].id)
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
                                  return const SizedBox(); // Empty placeholder with same dimensions
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (imageUrl.isNotEmpty &&
                        imageUrl !=
                            'https://via.placeholder.com/150?text=No+Image')
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 300,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object exception,
                          StackTrace? stackTrace,
                        ) {
                          return SizedBox(
                            height: 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  Text(
                                    'Could not load image',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StreamBuilder<bool>(
                          stream: _firestoreService.isPostLiked(
                            posts[index].id,
                            currentUser?.uid ?? '',
                          ),
                          builder: (context, snapshot) {
                            bool isLiked = snapshot.data ?? false;

                            return IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                if (currentUser == null) return;
                                _firestoreService.toggleLike(posts[index].id,
                                    currentUser.uid);
                              },
                            );
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
                                    bottom:
                                        MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                  ),
                                  child: DraggableScrollableSheet(
                                    maxChildSize: 1,
                                    initialChildSize: 1,
                                    minChildSize: 0.2,
                                    builder: (context, scrollController) {
                                      return CommentsPage(
                                        postId: posts[index].id,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Icon(Icons.chat_bubble_outline),
                        ),
                        const SizedBox(width: 6),
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('comments')
                                  .where('postId', isEqualTo: posts[index].id)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            int count =
                                snapshot.hasData
                                    ? snapshot.data!.docs.length
                                    : 0;
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
                                onTap: () {
                                  if (postData['userId'] == currentUser?.uid) {
                                    // Update page index to show profile tab
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const NavigationPage(
                                            initialIndex: 2), // 2 is the profile page index
                                      ),
                                    );
                                  } else {
                                    // Navigate to other user's profile
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserPage(
                                          userID: postData['userId'],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  '$username ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(text: caption),
                          ],
                        ),
                      ),
                    ),
                    // Comment Preview Section
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('comments')
                              .where('postId', isEqualTo: posts[index].id)
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Get total comment count
                        int commentCount = snapshot.data!.docs.length;
                        final comments = snapshot.data!.docs.take(
                          2,
                        ); // Take only first 2 comments

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...comments.map((comment) {
                                final commentData =
                                    comment.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 4.0,
                                    left: 20.0,
                                  ),
                                  child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.baseline,
                                          baseline: TextBaseline.alphabetic,
                                          child: GestureDetector(
                                            onTap: () {
                                              // Handle username tap
                                              if (postData['userId'] == currentUser?.uid) {
                                                // Update page index to show profile tab
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) => const NavigationPage(
                                                        initialIndex: 2), // 2 is the profile page index
                                                  ),
                                                );
                                              } else {
                                                // Navigate to other user's profile
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => UserPage(
                                                      userID: postData['userId'],
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              // Only show "View all comments" if there are more than 2 comments
                              if (commentCount > 2)
                                GestureDetector(
                                  onTap: () {
                                    showBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom,
                                          ),
                                          child: DraggableScrollableSheet(
                                            maxChildSize: 1,
                                            initialChildSize: 1,
                                            minChildSize: 0.2,
                                            builder: (
                                              context,
                                              scrollController,
                                            ) {
                                              return CommentsPage(
                                                postId: posts[index].id,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      bottom: 4.0,
                                    ),
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
