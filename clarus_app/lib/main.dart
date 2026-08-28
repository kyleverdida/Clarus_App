import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ClarusApp());
}

class ClarusApp extends StatelessWidget {
  const ClarusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clarus',
      debugShowCheckedModeBanner: false,
      theme: clarusTheme(),
      home: const LoginScreen(),
    );
  }
}
