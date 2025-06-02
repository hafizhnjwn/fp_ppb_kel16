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

  Future<void> createUserDocument(auth.User user, String username) async {
    return usersCollection.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': username,
      'bio': '',
      'profilePhotoUrl': '',
      'followers': [],
      'following': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return usersCollection.doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return usersCollection.doc(uid).update(data);
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
      'likes': [],
      'commentsCount': 0,
    });
  }

  Future<DocumentReference> createComment({
    required String postId,
    required String commentText,
    required String userId,
    required String username,
    required String userImageUrl,
  }) async {
    final docRef = await commentsCollection.add({
      'postId': postId,
      'text': commentText,
      'userId': userId,
      'username': username,
      'userImageUrl': userImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Increment commentsCount on the post
    await postsCollection.doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });
    return docRef;
  }
}
