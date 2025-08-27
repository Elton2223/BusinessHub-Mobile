import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../flutter_flow/flutter_flow_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _identificationController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _phoneController.text = user.phoneNumber?.toString() ?? '';
      _identificationController.text = user.identificationDoc?.toString() ?? '';
      _streetAddressController.text = user.streetAddress ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _postalCodeController.text = user.postalCode ?? '';
      _latitude = user.latitude;
      _longitude = user.longitude;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _identificationController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied')),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _streetAddressController.text = '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          _cityController.text = place.locality ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _postalCodeController.text = place.postalCode ?? '';
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Convert phone number to int
    int? phoneNumber;
    if (_phoneController.text.isNotEmpty) {
      phoneNumber = int.tryParse(_phoneController.text);
      if (phoneNumber == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number')),
        );
        return;
      }
    }

    // Convert identification doc to string
    String? identificationDoc;
    if (_identificationController.text.isNotEmpty) {
      identificationDoc = _identificationController.text;
    }

         // Convert selected image to base64 if available
     String? profilePhoto;
     if (_selectedImage != null) {
       try {
         print('📸 Processing selected image for upload...');
         final bytes = await _selectedImage!.readAsBytes();
         final base64Image = base64Encode(bytes);
         
         // Ensure proper base64 padding
         String paddedBase64 = base64Image;
         while (paddedBase64.length % 4 != 0) {
           paddedBase64 += '=';
         }
         
         profilePhoto = 'data:image/jpeg;base64,$paddedBase64';
         print('📸 Image converted to base64 successfully (${paddedBase64.length} characters)');
       } catch (e) {
         print('❌ Error processing image: $e');
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error processing image: $e')),
         );
         return;
       }
     } else {
       print('📸 No new image selected for upload');
     }

    final success = await authProvider.updateProfile(
      profilePhoto: profilePhoto,
      phoneNumber: phoneNumber,
      identificationDoc: identificationDoc,
      streetAddress: _streetAddressController.text.isNotEmpty ? _streetAddressController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      state: _stateController.text.isNotEmpty ? _stateController.text : null,
      postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      latitude: _latitude,
      longitude: _longitude,
    );

    if (success) {
      String message = 'Profile updated successfully';
      if (_selectedImage != null) {
        message += ' with new photo';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: FlutterFlowTheme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              Center(
                child: Column(
                  children: [
                                         CircleAvatar(
                       radius: 60,
                       backgroundImage: _selectedImage != null
                           ? FileImage(_selectedImage!)
                           : _getProfileImage(user?.profilePhoto),
                     ),
                    const SizedBox(height: 16),
                                         Wrap(
                       spacing: 12,
                       runSpacing: 8,
                       alignment: WrapAlignment.center,
                       children: [
                         ElevatedButton.icon(
                           onPressed: () => _pickImage(ImageSource.camera),
                           icon: const Icon(Icons.camera_alt),
                           label: const Text('Camera'),
                           style: ElevatedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                           ),
                         ),
                         ElevatedButton.icon(
                           onPressed: () => _pickImage(ImageSource.gallery),
                           icon: const Icon(Icons.photo_library),
                           label: const Text('Gallery'),
                           style: ElevatedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                           ),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // User Info Section
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Name and Surname (Read-only)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 400) {
                    // Use Row for wider screens
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: user?.name ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: user?.surname ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Surname',
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Use Column for narrower screens
                    return Column(
                      children: [
                        TextFormField(
                          initialValue: user?.name ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: user?.surname ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Surname',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email (Read-only)
              TextFormField(
                initialValue: user?.email ?? '',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Identification Document
              TextFormField(
                controller: _identificationController,
                decoration: const InputDecoration(
                  labelText: 'Identification Document',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your ID number',
                ),
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 32),
              
              // Location Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(_isLoadingLocation ? 'Getting...' : 'Get Current Location'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Street Address
              TextFormField(
                controller: _streetAddressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your street address',
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // City and State
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 400) {
                    // Use Row for wider screens
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                              hintText: 'Enter your city',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State/Province',
                              border: OutlineInputBorder(),
                              hintText: 'Enter your state',
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Use Column for narrower screens
                    return Column(
                      children: [
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                            hintText: 'Enter your city',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'State/Province',
                            border: OutlineInputBorder(),
                            hintText: 'Enter your state',
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Postal Code
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your postal code',
                ),
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 16),
              
              // Coordinates Display
              // if (_latitude != null && _longitude != null)
              //   Container(
              //     padding: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: Colors.grey[100],
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Coordinates:',
              //           style: Theme.of(context).textTheme.titleMedium,
              //         ),
              //         const SizedBox(height: 4),
              //         Text('Latitude: ${_latitude!.toStringAsFixed(6)}'),
              //         Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
              //       ],
              //     ),
              //   ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: authProvider.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Saving...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (authProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                                   ),
               ),
             ],
           ),
         ),
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
