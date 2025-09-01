import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminAccessWrapper extends StatelessWidget {
  final Widget adminContent;
  final Widget? fallbackContent;
  final String? customMessage;

  const AdminAccessWrapper({
    Key? key,
    required this.adminContent,
    this.fallbackContent,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user is logged in and is admin
        if (authProvider.currentUser == null) {
          return _buildAccessDeniedWidget(
            'Please log in to access this feature',
            Icons.login,
            Colors.orange,
          );
        }

        if (!authProvider.isAdmin) {
          return fallbackContent ?? _buildAccessDeniedWidget(
            customMessage ?? 'Access Denied',
            Icons.admin_panel_settings,
            Colors.red,
            subtitle: 'This feature is only available to administrators.',
          );
        }

        // User is admin, show admin content
        return adminContent;
      },
    );
  }

  Widget _buildAccessDeniedWidget(String title, IconData icon, Color color, {String? subtitle}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Admin Access Requirements:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRequirementItem(
                      'User ID must be 2',
                      Icons.person,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementItem(
                      'Or have admin privileges',
                      Icons.admin_panel_settings,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
