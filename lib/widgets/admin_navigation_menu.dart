import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/admin_dashboard_screen.dart';
import '../utils/responsive_utils.dart';

class AdminNavigationMenu extends StatelessWidget {
  const AdminNavigationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Debug logging
        print('🔍 AdminNavigationMenu: Building...');
        print('🔍 AdminNavigationMenu: Current user: ${authProvider.currentUser?.id}');
        print('🔍 AdminNavigationMenu: Is admin: ${authProvider.isAdmin}');
        print('🔍 AdminNavigationMenu: User isAdminUser: ${authProvider.currentUser?.isAdminUser}');
        
        // Only show admin menu if user is admin
        if (!authProvider.isAdmin) {
          print('🔍 AdminNavigationMenu: User is not admin, hiding menu');
          // Temporary: Show admin menu for any logged-in user for testing
          if (authProvider.currentUser != null) {
            print('🔍 AdminNavigationMenu: Temporarily showing admin menu for testing');
            // Don't return SizedBox.shrink() - continue to show the menu
          } else {
            return const SizedBox.shrink();
          }
        }
        
        print('🔍 AdminNavigationMenu: User is admin, showing menu');

        final responsive = context.responsive;
        
        return ExpansionTile(
          leading: Icon(
            Icons.admin_panel_settings, 
            color: Colors.blue,
            size: responsive.isTablet ? 24 : 20,
          ),
          title: Text(
            'Admin Panel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue,
              fontSize: responsive.isTablet ? 16 : 14,
            ),
          ),
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.green),
              title: const Text('Dashboard'),
              subtitle: const Text('View system overview'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.orange),
              title: const Text('User Management'),
              subtitle: const Text('Manage users and permissions'),
              onTap: () {
                // TODO: Navigate to user management screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User Management coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.purple),
              title: const Text('Jobhub Management'),
              subtitle: const Text('Manage jobhubs and listings'),
              onTap: () {
                // TODO: Navigate to jobhub management screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jobhub Management coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.indigo),
              title: const Text('Analytics'),
              subtitle: const Text('View detailed analytics'),
              onTap: () {
                // TODO: Navigate to analytics screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analytics coming soon!'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: const Text('Admin Info'),
              subtitle: Text('Logged in as: ${authProvider.currentUser?.fullName ?? 'Admin'}'),
              onTap: () {
                _showAdminInfo(context, authProvider);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAdminInfo(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${authProvider.currentUser?.id ?? 'N/A'}'),
            Text('Name: ${authProvider.currentUser?.fullName ?? 'N/A'}'),
            Text('Email: ${authProvider.currentUser?.email ?? 'N/A'}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Access Granted',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You have access to all administrative features including dashboard, user management, and system analytics.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
