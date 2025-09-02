import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'userManagement/register.dart';
import 'userManagement/verify_email.dart';
import 'userManagement/login.dart';
import 'userManagement/profile_screen.dart';
import 'home_page.dart';
import 'hubs/hub_list.dart';
import 'hubs/hub_apply.dart';
import 'screens/admin_dashboard_screen.dart';
import 'config/env_config.dart';
import 'config/api_config.dart';
import 'providers/auth_provider.dart';
import 'examples/neumorphic_examples.dart';

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
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
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
        home: const AuthWrapper(),
        routes: {
          '/verify_email': (context) => const VerifyEmailScreen(),
          '/login': (context) => const LoginWidget(),
          '/register': (context) => const RegisterWidget(),
          '/profile': (context) => const ProfileScreen(),
          '/home': (context) => const HomePage(),
          '/hub-list': (context) => const HubListPage(),
          '/hub-apply': (context) => const HubApplyPage(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/neumorphic-examples': (context) => const NeumorphicExamples(),
        },
      ),
    );
  }
}

// Wrapper to check authentication state and redirect accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth status
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in, go to home page
        if (authProvider.currentUser != null) {
          print('🔍 AuthWrapper: User is logged in, redirecting to home');
          print('🔍 AuthWrapper: User ID: ${authProvider.currentUser?.id}');
          print('🔍 AuthWrapper: User isAdmin: ${authProvider.currentUser?.isAdmin}');
          return const HomePage();
        }
        
        // If no user, show login page
        print('🔍 AuthWrapper: No user logged in, showing login page');
        return const LoginWidget();
      },
    );
  }
}
