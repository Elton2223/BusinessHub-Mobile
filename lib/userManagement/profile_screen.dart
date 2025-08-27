import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('No user data available'),
            ),
          );
        }

        // Debug: Print user profile photo info
        print('🔍 Profile Screen - User profile photo: ${user.profilePhoto}');
        print('🔍 Profile Screen - User profile photo length: ${user.profilePhoto?.length}');
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: FlutterFlowTheme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _getProfileImage(user.profilePhoto),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${user.name ?? ''} ${user.surname ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Personal Information Section
                _buildSection(
                  context,
                  'Personal Information',
                  [
                    _buildInfoRow('Name', user.name ?? 'Not set'),
                    _buildInfoRow('Surname', user.surname ?? 'Not set'),
                    _buildInfoRow('Email', user.email ?? 'Not set'),
                    _buildInfoRow('Phone Number', user.phoneNumber?.toString() ?? 'Not set'),
                    _buildInfoRow('Identification Doc', user.identificationDoc?.toString() ?? 'Not set'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Location Information Section
                _buildSection(
                  context,
                  'Location Information',
                  [
                    _buildInfoRow('Street Address', user.streetAddress ?? 'Not set'),
                    _buildInfoRow('City', user.city ?? 'Not set'),
                    _buildInfoRow('State/Province', user.state ?? 'Not set'),
                    _buildInfoRow('Postal Code', user.postalCode ?? 'Not set'),
                    if (user.latitude != null && user.longitude != null)
                      _buildInfoRow('Coordinates', '${user.latitude!.toStringAsFixed(6)}, ${user.longitude!.toStringAsFixed(6)}'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Ratings Section
                if (user.ratings != null)
                  _buildSection(
                    context,
                    'Ratings',
                    [
                      _buildRatingRow(user.ratings!),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: FlutterFlowTheme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Rating',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: index < rating ? Colors.amber : Colors.grey,
                  size: 20,
                );
              }),
            ),
          ),
          Text(
            '$rating/5',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String? profilePhoto) {
    if (profilePhoto == null || profilePhoto.isEmpty) {
      return const AssetImage('images/logo.png');
    }

    try {
      if (profilePhoto.startsWith('data:image/')) {
        // Handle base64 image
        final parts = profilePhoto.split(',');
        if (parts.length != 2) {
          print('⚠️ Invalid base64 image format');
          return const AssetImage('images/logo.png');
        }

        String base64Data = parts[1];
        
        // Remove any whitespace or newlines
        base64Data = base64Data.trim().replaceAll(RegExp(r'\s+'), '');
        
        // Ensure proper base64 padding
        while (base64Data.length % 4 != 0) {
          base64Data += '=';
        }

        // Validate base64 characters
        if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(base64Data)) {
          print('⚠️ Invalid base64 characters');
          return const AssetImage('images/logo.png');
        }

        try {
          final bytes = base64Decode(base64Data);
          if (bytes.isEmpty) {
            print('⚠️ Empty base64 data');
            return const AssetImage('images/logo.png');
          }
          return MemoryImage(bytes);
        } catch (e) {
          print('⚠️ Error decoding base64 image: $e');
          return const AssetImage('images/logo.png');
        }
      } else {
        // Handle network image
        return NetworkImage(profilePhoto);
      }
    } catch (e) {
      print('⚠️ Error processing profile image: $e');
      return const AssetImage('images/logo.png');
    }
  }
}
