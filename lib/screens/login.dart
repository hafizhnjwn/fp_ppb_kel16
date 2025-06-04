// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_pbb_kel6/services/imgur_api.dart';
import 'package:image_picker/image_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final debug = true; //fast login and test function

  bool _isLoading = false;
  String _errorCode = "";

  void navigateRegister() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'register');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  /// Test Function tanpa login
  void _debugLogin() async {
    _emailController.text = "test2@gmail.com";
    _passwordController.text = "1234567890";
    signIn();
  }

  void signIn() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorCode = e.code;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff152127),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 100),
              const SizedBox(
                height: 72,
                width: 72,
                child: Image(
                  image: AssetImage(
                    'assets/images/Instagram_Glyph_Gradient.png',
                  ),
                ),
              ),
              const SizedBox(height: 100),
              TextField(
                cursorColor: Colors.white,
                controller: _emailController,
                decoration: InputDecoration(
                  label: Text('Email'),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Color(0xff4599fe),
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Color(0xff375563),
                      width: 1.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                cursorColor: Colors.white,
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text('Password'),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Color(0xff4599fe), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Color(0xff375563),
                      width: 1.5,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              _errorCode != ""
                  ? Column(
                    children: [Text(_errorCode), const SizedBox(height: 12)],
                  )
                  : const SizedBox(height: 0),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xff0064e0),
                  side: BorderSide(width: 1.5, color: Color(0xff0064e0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: signIn,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color(0xff4599fe), // Text/icon color
                  side: BorderSide(
                    width: 1.5,
                    color: Color(0xff4599fe),
                  ), // ✅ Correct place for border
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: navigateRegister,
                child: const Text(
                    'Create New Account',
                    style: TextStyle(
                    color: Color(0xff4599fe),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (debug)...{
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Color(0xff4599fe), // Text/icon color
                      side: BorderSide(
                        width: 1.5,
                        color: Color(0xff4599fe),
                      ), // ✅ Correct place for border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _debugLogin,
                    child: const Text(
                      'debug Auto login',
                      style: TextStyle(
                        color: Color(0xff4599fe),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
