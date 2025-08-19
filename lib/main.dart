import 'package:flutter/material.dart';
import 'userManagement/register.dart';
import 'userManagement/verify_email.dart';
import 'userManagement/login.dart';
import 'demo_screen.dart';
import 'home_page.dart';
import 'hubs/hub_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusinessHub Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'GoogleFonts.poppins',
      ),
      home: const DemoScreen(),
      routes: {
        '/verify_email': (context) => const VerifyEmailScreen(),
        '/login': (context) => const LoginWidget(),
        '/register': (context) => const RegisterWidget(),
        '/demo': (context) => const DemoScreen(),
        '/home': (context) => const HomePage(),
        '/hub-list': (context) => const HubListPage(),
      },
    );
  }
}
