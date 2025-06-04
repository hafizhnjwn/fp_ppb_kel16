// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/services/firestore_service.dart';
import 'package:fp_pbb_kel6/services/imgur_api.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  int steps = 0;
  final defaultProfilePicture =
      "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small_2x/default-avatar-icon-of-social-media-user-vector.jpg";

  bool _isLoading = false;
  String _errorCode = "";
  String _profilePictureUrl = "";
  XFile? _profilePictFile;

  final Map<int, String> _mainTitle = {
    0: "Register",
    1: "What's Your Name?",
    2: "Create a Username",
    3: "Add a profile picture",
  };

  final Map<int, String> _subMainTitle = {
    0: "Add an email address at which you can be contacted. Create a password with at least 6 letters or numbers. ",
    1: "Add your name so that friends can find you",
    2: "Add a username. You can change it anytime",
    3: "Add a profile picture so that your friends know it's you. Everyone will be able to see your picture.",
  };

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  String _generateRandomUsername(String uid) {
    String username = uid.substring(0, 6);
    return username;
  }

  @override
  void initState() {
    super.initState();
    steps = 0;
  }

  void _changeProfilePicture() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePictFile = image;
      });
    } else {
      setState(() {
        _errorCode = "Please select an image";
      });
    }
  }

  void nextFunction() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    switch (steps) {
      case 0:
        // email and password
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          final randomusername = _generateRandomUsername(
            FirebaseAuth.instance.currentUser!.uid,
          );
          await _firestoreService.createUserDocument(
            FirebaseAuth.instance.currentUser!,
            randomusername,
            randomusername,
            defaultProfilePicture,
          );
          steps++;
        } on FirebaseAuthException catch (e) {
          setState(() {
            _errorCode = e.code;
          });
        }
        break;
      case 1:
        // Full Name
        if (_fullnameController.text.isEmpty) {
          setState(() {
            _errorCode = "Please enter your name";
          });
        } else if (_fullnameController.text.length < 3 ||
            _fullnameController.text.length > 30) {
          setState(() {
            _errorCode = "Your name can only be 3-30 characters long";
          });
        } else {
          steps++;
        }
        break;
      case 2:
        // Username
        if (_usernameController.text.isEmpty) {
          setState(() {
            _errorCode = "Please enter your username";
          });
        } else if (_usernameController.text.length < 3 ||
            _usernameController.text.length > 30) {
          setState(() {
            _errorCode = "Your username can only be 3-30 characters long";
          });
        } else if (await _firestoreService.doesUsernameExist(
          _usernameController.text,
        )) {
          setState(() {
            _errorCode = "Username already exists";
          });
        } else {
          steps++;
        }
        break;
      case 3:
        // 3 is the last step
        if (_profilePictFile == null) {
          _profilePictureUrl = defaultProfilePicture;
        } else {
          _profilePictureUrl = await ImgurAPI.uploadImageorVideo(
            _profilePictFile!,
          );
        }
        try {
          await _firestoreService
              .updateUserProfile(FirebaseAuth.instance.currentUser!.uid, {
                "username": _usernameController.text,
                "name": _fullnameController.text,
                "profilePhotoUrl": _profilePictureUrl,
              });
          navigateHome();
        } on FirebaseAuthException catch (e) {
          setState(() {
            _errorCode = e.code;
          });
        }
        break;
      default:
        print("steps: $steps error");
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget registerTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return TextField(
      cursorColor: Colors.white,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        label: Text(label),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xff4599fe), width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xff375563), width: 1.5),
        ),
        fillColor: Colors.transparent,
        filled: true,
      ),
    );
  }

  List<Widget> newProfileStepsWidgets() {
    late List<Widget> widgets;
    switch (steps) {
      // email and password
      case 0:
        widgets = [
          registerTextField("Email", _emailController),
          const SizedBox(height: 18),
          registerTextField("Password", _passwordController, obscureText: true),
        ];
        break;
      // Full Name
      case 1:
        widgets = [registerTextField("Your name", _fullnameController)];
        break;
      // Username
      case 2:
        widgets = [registerTextField("Username", _usernameController)];
        break;
      // Profile Picture
      case 3:
        widgets = [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 120,
            backgroundImage:
                _profilePictFile == null
                    ? NetworkImage(defaultProfilePicture)
                    : FileImage(File(_profilePictFile!.path)),
          ),
          const SizedBox(height: 150),
        ];
        break;
      default:
        widgets = [Center(child: Text("error steps not registered"))];
        break;
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            steps == 0
                ? navigateLogin()
                : setState(() {
                  steps--;
                });
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        backgroundColor: Color(0xff152127),
      ),
      backgroundColor: Color(0xff152127),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Center(
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _mainTitle[steps] ?? "Bugged",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _subMainTitle[steps] ?? "",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...newProfileStepsWidgets(),
              const SizedBox(height: 12),
              _errorCode != ""
                  ? Column(
                    children: [Text(_errorCode), const SizedBox(height: 12)],
                  )
                  : const SizedBox(height: 0),
              if (steps == 3) ...{
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(width: 1.5, color: Color(0xff0064e0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _changeProfilePicture,
                  child: const Text(
                    'Change Profile Picture',
                    style: TextStyle(
                      color: Color(0xff4599fe),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 1),
              },
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xff0064e0),
                  side: BorderSide(width: 1.5, color: Color(0xff0064e0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: nextFunction,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    steps++;
                  });
                },
                child: Text("goblok"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (steps == 0) ...{
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: navigateLogin,
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
