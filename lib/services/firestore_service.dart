import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance
      .collection('posts');
  final CollectionReference commentsCollection = FirebaseFirestore.instance
      .collection('comments');
  final CollectionReference likesCollection = FirebaseFirestore.instance
      .collection('likes');

  Future<void> createUserDocument(
    auth.User user,
    String username,
    String name,
    String profilePhotoUrl,
  ) async {
    return usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'username': username,
      'bio': '',
      'profilePhotoUrl': profilePhotoUrl,
      'followers': [],
      'following': [],
      'followersCount': 0,
      'followingCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return usersCollection.doc(uid).get();
  }

  Stream<String> getUserProfilePhotoUrl(String userId) {
    return usersCollection
        .doc(userId)
        .snapshots()
        .map((snapshot) => 
            (snapshot.data() as Map<String, dynamic>)?['profilePhotoUrl'] as String? ?? 
            'https://via.placeholder.com/32?text=No+Image'
        );
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return usersCollection.doc(uid).update(data);
  }

  Future<bool> doesUsernameExist(String username) async {
    final querySnapshot =
        await usersCollection
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Stream<QuerySnapshot> userPostsProfileStream(String userId) {
    return postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> createPost({
    required String userId,
    required String username,
    required String imageUrl,
    required String caption,
  }) {
    return postsCollection.add({
      'userId': userId,
      'username': username,
      'imageUrl': imageUrl,
      'caption': caption,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
    });
  }

  Future<void> createComment({
    required String postId,
    required String userId,
    required String username,
    required String commentText,
    required String profilePhotoUrl,
  }) async {
    // Add the comment
    await commentsCollection.add({
      'postId': postId,
      'text': commentText,
      'userId': userId,
      'username': username,
      'profilePhotoUrl': profilePhotoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Check if post is liked by user
  Stream<bool> isPostLiked(String postId, String userId) {
    return likesCollection
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // Toggle like status
  Future<void> toggleLike(String postId, String userId) async {
    final querySnapshot =
        await likesCollection
            .where('postId', isEqualTo: postId)
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Unlike
      await likesCollection.doc(querySnapshot.docs.first.id).delete();
    } else {
      // Like
      await likesCollection.add({
        'postId': postId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
