import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/app_theme.dart';
import 'package:fp_pbb_kel6/services/firestore_service.dart';
import 'package:shimmer/shimmer.dart';

class UserPage extends StatefulWidget {
  /// User Page for authenticated user and other user via uid
  const UserPage({super.key, required this.userID});
  final String userID;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Map<String, dynamic> currentUser;
  late bool isAuthUser;
  bool isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  int postCount = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final userID = widget.userID;
    isAuthUser =
        userID ==
        FirebaseAuth.instance.currentUser!.uid; // is auth user's page check

    final docSnapshot = await _firestoreService.getUserData(userID);
    currentUser = docSnapshot.data() as Map<String, dynamic>;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(title: Text(currentUser["username"])),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture and Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 30,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: currentUser["profilePhotoUrl"],
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser["name"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postCount.toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "posts",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentUser["followersCount"]
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "followers",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentUser["followingCount"]
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "following",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Buttons
                    SizedBox(height: 10),
                    Text(currentUser["bio"]),
                    SizedBox(height: 14),
                    SizedBox(
                      height: 34,
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: greyButtonStyle,
                              onPressed: () {},
                              child: Text(
                                isAuthUser ? "Edit Profile" : "Follow",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: greyButtonStyle,
                              onPressed: () {},
                              child: Text(
                                "Share profile",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_sharp)),
                  Tab(icon: Icon(Icons.person_pin_outlined)),
                ],
              ),
              SizedBox(height: 2),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.userPostsProfileStream(
                        currentUser["uid"],
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Something went wrong: [${snapshot.error}]',
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return SizedBox.expand(
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white, // border color
                                        width: 1.5, // border width
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 59,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "No posts yet",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final docs = snapshot.data!.docs;
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                              ),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final imageUrl = docs[index]["imageUrl"];
                            return Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder:
                                      (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(
                                    Icons.photo_library_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    Center(child: Text("Placeholder")),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
