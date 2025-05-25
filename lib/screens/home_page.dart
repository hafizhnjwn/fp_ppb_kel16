import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userSnaphot});
  final AsyncSnapshot<User?> userSnaphot;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AsyncSnapshot<User?> snapshot;

  @override
  void initState() {
    super.initState();
    snapshot = widget.userSnaphot;
  }

  void logout(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Instagram", style: TextStyle(fontFamily: "Instagram Headline", fontSize: 30),),
      ),
       body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as ${snapshot.data?.email}'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => logout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}