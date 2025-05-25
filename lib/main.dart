import 'package:fp_pbb_kel6/app_theme.dart';
import 'package:fp_pbb_kel6/screens/nav_page.dart';
import 'package:fp_pbb_kel6/screens/login.dart';
import 'package:fp_pbb_kel6/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      initialRoute: 'login',
      theme: darkTheme,
      routes: {
      'home': (context) => const NavigationPage(),
      'login': (context) => const LoginScreen(),
      'register': (context) => const RegisterScreen(),
    });
  }
}