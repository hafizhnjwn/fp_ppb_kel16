import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorCode = "";

  void navigateLogin() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateHome() {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, 'home');
  }

  void register() async {
    setState(() {
      _isLoading = true;
      _errorCode = "";
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      navigateLogin();
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
              const SizedBox(height: 50),
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Add an email address at which you can be contacted. Create a password with at least 6 letters or numbers. ",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                cursorColor: Colors.white,
                controller: _emailController,
                decoration: InputDecoration(
                  label: Text('Email'),
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
                onPressed: register,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: navigateLogin,
                    child: const Text('Login', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
