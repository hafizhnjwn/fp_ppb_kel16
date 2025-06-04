import 'package:fp_pbb_kel6/screens/home_page.dart';
import 'package:fp_pbb_kel6/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/screens/user_page.dart';
import 'package:fp_pbb_kel6/screens/create_post.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentPageIndex = 0;

  int _getPageIndex(int navIndex) {
    switch (navIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      default:
        return 0;
    }
  }

  int _getNavIndex(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Widget> pages = [
            HomePage(userSnaphot: snapshot),
            const Center(child: Text("Explore Page")),
            UserPage(userID: snapshot.data!.uid),
          ];

          return Scaffold(
            body: pages[_currentPageIndex],
            bottomNavigationBar: Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: Colors.grey[900]!, width: 0.5)),
              ),
              child: NavigationBar(
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                indicatorColor: Colors.transparent,
                backgroundColor: Colors.black,
                selectedIndex: _getNavIndex(_currentPageIndex),
                onDestinationSelected: (int navIndex) {
                  if (navIndex == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreatePostScreen(),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _currentPageIndex = _getPageIndex(navIndex);
                  });
                },
                destinations: const <Widget>[
                  NavigationDestination(
                    selectedIcon: Icon(Icons.home),
                    icon: Icon(Icons.home_outlined),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.search),
                    icon: Icon(Icons.search_outlined),
                    label: 'Explore',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.add_box),
                    icon: Icon(Icons.add_box_outlined),
                    label: 'Create',
                  ),
                  NavigationDestination(
                    selectedIcon: Icon(Icons.person),
                    icon: Icon(Icons.person_outlined),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}