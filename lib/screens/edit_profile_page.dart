import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.userSnaphot});
  final AsyncSnapshot<User?> userSnaphot;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
    );
  }
}
