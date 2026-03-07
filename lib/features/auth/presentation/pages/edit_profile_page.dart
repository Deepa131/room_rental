import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/auth/domain/entities/auth_entity.dart';
import 'package:room_rental/features/auth/presentation/view_model/auth_view_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  File? _selectedImage;
  String? _profilePictureUrl;
  bool _pictureRemoved = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userSession = ref.read(userSessionServiceProvider);
    final authState = ref.read(authViewModelProvider);
    _fullNameController = TextEditingController(text: userSession.getUserFullName() ?? '');
    _emailController = TextEditingController(text: userSession.getUserEmail() ?? '');
    
    final rawProfilePicture = authState.authEntity?.profilePicture;
    
    if (rawProfilePicture != null && 
        rawProfilePicture.isNotEmpty && 
        rawProfilePicture != 'default-profile.png' &&
        rawProfilePicture != 'null' &&
        !rawProfilePicture.contains('default')) {
      _profilePictureUrl = rawProfilePicture;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _pictureRemoved = false;
      });
      
      showMySnackBar(
        context: context,
        message: 'Image selected. Click Update Profile to save.',
      );
    }
  }

  Future<void> _removeProfilePicture() async {
    if (_pictureRemoved) {
      setState(() {
        _pictureRemoved = false;
        final authState = ref.read(authViewModelProvider);
        final rawProfilePicture = authState.authEntity?.profilePicture;
        if (rawProfilePicture != null && 
            rawProfilePicture.isNotEmpty && 
            rawProfilePicture != 'default-profile.png' &&
            rawProfilePicture != 'null' &&
            !rawProfilePicture.contains('default')) {
          _profilePictureUrl = rawProfilePicture;
        }
      });
      showMySnackBar(
        context: context,
        message: 'Photo removal cancelled',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _selectedImage = null;
      _profilePictureUrl = null;
      _pictureRemoved = true;
    });

    showMySnackBar(
      context: context,
      message: 'Profile picture will be removed when you update your profile. Click the button again to undo.',
    );
  }


  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    final userRole = userSession.getUserRole();

    if (userId == null || userRole == null) {
      showMySnackBar(
        context: context,
        message: 'User session not found. Please login again.',
        color: Colors.red,
      );
      return;
    }

    final pictureToSend = _pictureRemoved ? '' : _profilePictureUrl;

    final updatedUser = AuthEntity(
      userId: userId,
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: '', 
      role: userRole,
      profilePicture: pictureToSend,
    );

    final result = await ref.read(authViewModelProvider.notifier).updateProfile(userId, updatedUser, imageFile: _selectedImage);

    result.fold(
      (failure) {
        showMySnackBar(
          context: context,
          message: failure.message,
          color: Colors.red,
        );
      },
      (user) {
        showMySnackBar(
          context: context,
          message: 'Profile updated successfully',
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.read(userSessionServiceProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : _profilePictureUrl != null
                              ? NetworkImage(ImageUrlHelper.getProfilePictureUrl(_profilePictureUrl!))
                              : null,
                      child: _selectedImage == null && _profilePictureUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                      onBackgroundImageError: _profilePictureUrl != null
                          ? (exception, stackTrace) {
                              debugPrint('Failed to load profile picture: $exception');
                            }
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Role 
              TextFormField(
                initialValue: userSession.getUserRole() ?? '',
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
                enabled: false,
              ),

              const SizedBox(height: 28),

              MyButton(
                text: 'Update Profile',
                color: AppColors.primary,
                onPressed: _updateProfile,
              ),

              const SizedBox(height: 14),
              if (_profilePictureUrl != null || _selectedImage != null || _pictureRemoved)
                MyButton(
                  onPressed: _removeProfilePicture,
                  text: _pictureRemoved ? 'Undo Remove Photo' : 'Remove Photo',
                  color: _pictureRemoved ? Colors.orange.shade100 : const Color.fromARGB(255, 221, 79, 93),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
