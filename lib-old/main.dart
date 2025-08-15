import 'package:flutter/material.dart';
import 'userManagement/register.dart';
import 'userManagement/verify_email.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusinessHub Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 103, 58, 183)),
        useMaterial3: true,
      ),
      home: const RegisterWidget(),
      routes: {
        '/verify_email': (context) => const VerifyEmailScreen(),
      },
    );
  }
}
