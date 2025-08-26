import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userManagement/register.dart';
import 'userManagement/verify_email.dart';
import 'userManagement/login.dart';
import 'home_page.dart';
import 'hubs/hub_list.dart';
import 'hubs/hub_apply.dart';
import 'config/env_config.dart';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.initialize();
  
  // Debug environment variables (remove in production)
      if (EnvConfig.debugMode) {
      print('Environment: ${EnvConfig.environment}');
      print('API Base URL: ${ApiConfig.baseUrl}');
      print('User Management URL: ${ApiConfig.userManagementUrl}');
      print('App Name: ${EnvConfig.appName}');
    }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
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
        home: const LoginWidget(),
        routes: {
          '/verify_email': (context) => const VerifyEmailScreen(),
          '/login': (context) => const LoginWidget(),
          '/register': (context) => const RegisterWidget(),
          '/home': (context) => const HomePage(),
          '/hub-list': (context) => const HubListPage(),
          '/hub-apply': (context) => const HubApplyPage(),
        },
      ),
    );
  }
}
