import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_provider.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../model/user_model.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLaptop = screenWidth > 900;
    
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
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: FlutterFlowTheme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.logout, size: isTablet ? 28 : 24),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
          body: Center(
            child: Container(
              width: isLaptop ? 900 : double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: isTablet ? 80 : 60,
                        backgroundImage: _getProfileImage(user.profilePhoto),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${user.name ?? ''} ${user.surname ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating Display at the top
                      if (user.ratings != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 16,
                            vertical: isTablet ? 10 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                            border: Border.all(color: Colors.amber.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${user.ratings}/5',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                        icon: Icon(Icons.edit, size: isTablet ? 22 : 20),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: isTablet ? 18 : 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 32 : 24,
                            vertical: isTablet ? 16 : 12,
                          ),
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
                    _buildInfoRow(context, 'Name', user.name ?? 'Not set'),
                    _buildInfoRow(context, 'Surname', user.surname ?? 'Not set'),
                    _buildInfoRow(context, 'Email', user.email ?? 'Not set'),
                    _buildInfoRow(context, 'Phone Number', user.phoneNumber?.toString() ?? 'Not set'),
                    _buildIdentificationRow(context, user, authProvider),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Location Information Section
                _buildSection(
                  context,
                  'Location Information',
                  [
                    _buildInfoRow(context, 'Street Address', user.streetAddress ?? 'Not set'),
                    _buildInfoRow(context, 'City', user.city ?? 'Not set'),
                    _buildInfoRow(context, 'State/Province', user.state ?? 'Not set'),
                    _buildInfoRow(context, 'Postal Code', user.postalCode ?? 'Not set'),
                    // if (user.latitude != null && user.longitude != null)
                    //   _buildInfoRow('Coordinates', '${user.latitude!.toStringAsFixed(6)}, ${user.longitude!.toStringAsFixed(6)}'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // // Ratings Section
                // if (user.ratings != null)
                //   _buildSection(
                //     context,
                //     'Ratings',
                //     [
                //       _buildRatingRow(user.ratings!),
                //     ],
                //   ),
              ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildIdentificationRow(BuildContext context, UserModel user, AuthProvider authProvider) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final value = user.identificationDoc?.toString() ?? 'Not set';
    return InkWell(
      onTap: () => _showUploadIdDocumentDialog(context, user, authProvider),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isTablet ? 180 : 120,
              child: Text(
                'Identification Doc',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                  Icon(Icons.upload_file, size: 20, color: FlutterFlowTheme.of(context).primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showUploadIdDocumentDialog(
    BuildContext context,
    UserModel user,
    AuthProvider authProvider,
  ) async {
    File? selectedFile;
    bool isUploading = false;

    await showDialog(
      context: context,
      barrierDismissible: !isUploading,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Center(child: Text('Upload ID Document')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please read the following before uploading:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildInstructionBullet(
                          'This ID document will be uploaded for validation check.',
                        ),
                        const SizedBox(height: 6),
                        _buildInstructionBullet(
                          'Your ID must be certified with not less than 3 months.',
                        ),
                        const SizedBox(height: 6),
                        _buildInstructionBullet(
                          'If verification isn\'t approved, your profile won\'t be as functional.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (selectedFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedFile!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1600,
                                imageQuality: 85,
                              );
                              if (picked != null && context.mounted) {
                                setState(() => selectedFile = File(picked.path));
                              }
                            },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(selectedFile == null ? 'Choose ID document' : 'Change document'),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isUploading || selectedFile == null
                    ? null
                    : () async {
                        setState(() => isUploading = true);
                        try {
                          final bytes = await selectedFile!.readAsBytes();
                          String base64Image = base64Encode(bytes);
                          while (base64Image.length % 4 != 0) base64Image += '=';
                          final idDocValue = 'data:image/jpeg;base64,$base64Image';

                          final success = await authProvider.updateProfile(
                            identificationDoc: idDocValue,
                          );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'ID document uploaded successfully. It will be validated shortly.'
                                      : authProvider.errorMessage ?? 'Upload failed.',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() => isUploading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildInstructionBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: FlutterFlowTheme.of(context).primaryColor,
            fontSize: isTablet ? 22 : 20,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 180 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildRatingRow(int rating) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       children: [
  //         const SizedBox(
  //           width: 120,
  //           child: Text(
  //             'Rating',
  //             style: TextStyle(
  //               fontWeight: FontWeight.w600,
  //               color: Colors.grey,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Row(
  //             children: List.generate(5, (index) {
  //               return Icon(
  //                 index < rating ? Icons.star : Icons.star_border,
  //                 color: index < rating ? Colors.amber : Colors.grey,
  //                 size: 20,
  //               );
  //             }),
  //           ),
  //         ),
  //         Text(
  //           '$rating/5',
  //           style: const TextStyle(
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
