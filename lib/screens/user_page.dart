import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/app_theme.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.userSnaphot});
  final AsyncSnapshot<User?> userSnaphot;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late AsyncSnapshot<User?> snapshot;

  @override
  void initState() {
    super.initState();
    snapshot = widget.userSnaphot;
    final askdjfhalslkjdfh= 123455;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text("Username")),
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
                      CircleAvatar(
                        // Todo: get user image
                        radius: 48,
                        backgroundImage: NetworkImage(
                          "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg",
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Username",
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
                                        "0",
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
                                        "509",
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
                                        "454",
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
                  Text("Synopsis Placeholder"),
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
                              "Edit profile",
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
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      // Todo: get user posts
                      return Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Image(
                            image: NetworkImage(
                              "https://picsum.photos/200/200",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.photo_library_rounded),
                          ),
                        ],
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
