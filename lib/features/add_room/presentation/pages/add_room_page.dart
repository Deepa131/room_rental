import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../room_type/domain/entities/room_type_entity.dart';
import '../widgets/media_picker_bottom_sheet.dart';
import '../widgets/media_upload_section.dart';
import '../widgets/form_section_header.dart';
import '../widgets/styled_text_field.dart';

class AddRoomPage extends ConsumerStatefulWidget {
  const AddRoomPage({super.key});

  @override
  ConsumerState<AddRoomPage> createState() => _AddRoomPageState();
}
class _AddRoomPageState extends ConsumerState<AddRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  RoomTypeEntity? _selectedRoomType;
  final List<String> _imageUrls = [];
  final List<String> _videoUrls = [];
  final List<File?> _localImageFiles = [];
  final List<File?> _localVideoFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load room types immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(typeViewmodelProvider.notifier).getAllTypes();
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text("Permission Required"),
          content: const Text(
            "This feature requires permission to access your camera or microphone."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              }, 
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      return false;
    }
    return false;
  }

  // Pick image from camera/gallery
  Future<void> _pickImage(ImageSource source) async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    final imageFile = File(file.path);
    
    // Show local file immediately
    setState(() {
      _localImageFiles.add(imageFile);
      _imageUrls.add(''); // Placeholder for URL that will be filled after upload
    });

    // Upload in background
    final url = await ref
        .read(addRoomViewModelProvider.notifier)
        .uploadRoomImage(imageFile);

    if (url != null) {
      print('DEBUG: Adding image URL to list: $url');
      setState(() {
        final index = _imageUrls.length - 1;
        _imageUrls[index] = url;
      });
    } else {
      // Remove if upload failed
      setState(() {
        _localImageFiles.removeLast();
        _imageUrls.removeLast();
      });
    }
  }

  // Record video using camera
  Future<void> _pickVideo() async {
    final hasCameraPermission = await _requestPermission(Permission.camera);
    if (!hasCameraPermission) return;

    final hasMicPermission = await _requestPermission(Permission.microphone);
    if (!hasMicPermission) return;

    final file = await _picker.pickVideo(
      source: ImageSource.camera, 
      maxDuration: const Duration(minutes: 1),
    );
    if (file == null) return;

    final videoFile = File(file.path);
    
    // Show local file immediately
    setState(() {
      _localVideoFiles.add(videoFile);
      _videoUrls.add(''); // Placeholder for URL that will be filled after upload
    });

    // Upload in background
    final url = await ref
        .read(addRoomViewModelProvider.notifier)
        .uploadRoomVideo(videoFile);

    if (url != null) {
      setState(() {
        final index = _videoUrls.length - 1;
        _videoUrls[index] = url;
      });
    } else {
      // Remove if upload failed
      setState(() {
        _localVideoFiles.removeLast();
        _videoUrls.removeLast();
      });
    }
  }

  // show media picker bottom sheet
    void _showMediaPicker() {
      MediaPickerBottomSheet.show(
        context, 
        onCameraTap: () => _pickImage(ImageSource.camera), 
        onGalleryTap: () => _pickImage(ImageSource.gallery), 
        onVideoTap: _pickVideo,
      );
    }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoomType == null) {
      showMySnackBar(
        context: context,
        message: 'Please select room type',
        color: Colors.red,
      );
      return;
    }

    // Parse price - remove "Rs. " prefix if present
    String priceText = _priceController.text.trim();
    if (priceText.startsWith('Rs.')) {
      priceText = priceText.replaceFirst('Rs.', '').trim();
    }
    
    double monthlyPrice;
    try {
      monthlyPrice = double.parse(priceText);
    } catch (e) {
      showMySnackBar(
        context: context,
        message: 'Please enter a valid price',
        color: Colors.red,
      );
      return;
    }

    final userSession = ref.read(userSessionServiceProvider);
    final ownerId = userSession.getUserId();
    
    print('DEBUG ownerId: $ownerId');

    if (ownerId == null || ownerId.isEmpty) {
      showMySnackBar(
        context: context,
        message: 'User not authenticated. Please login again.',
        color: Colors.red,
      );
      return;
    }

    await ref.read(addRoomViewModelProvider.notifier).createRoom(
          ownerId: ownerId,
          ownerContactNumber: _contactController.text.trim(),
          roomTitle: _titleController.text.trim(),
          monthlyPrice: monthlyPrice,
          location: _locationController.text.trim(),
          roomType: _selectedRoomType!,
          description: _descriptionController.text.trim(),
          images: _imageUrls,
          videos: _videoUrls,
        );
  }

  @override
  Widget build(BuildContext context) {
    final addRoomState = ref.watch(addRoomViewModelProvider);
    final roomTypeState = ref.watch(typeViewmodelProvider);

    // Load room types on first build if not loaded yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (roomTypeState.status == RoomTypeStatus.initial) {
        ref.read(typeViewmodelProvider.notifier).getAllTypes();
      }
    });

    if (roomTypeState.types.isNotEmpty && _selectedRoomType == null) {
      _selectedRoomType = roomTypeState.types.first;
  }

    ref.listen(addRoomViewModelProvider, (prev, next) {
      if (next.status == AddRoomStatus.created) {
        showMySnackBar(
          context: context,
          message: 'Room added successfully',
        );
        Navigator.pop(context);
      }

      if (next.status == AddRoomStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? 'Something went wrong',
          color: Colors.red,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormSectionHeader(title: 'Room Details'),
              const SizedBox(height: 12),

              StyledTextField(
                controller: _titleController,
                hintText: 'Room title',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              StyledTextField(
                controller: _priceController,
                hintText: 'Monthly price',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              StyledTextField(
                controller: _locationController,
                hintText: 'Location',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              StyledTextField(
                controller: _contactController,
                hintText: 'Contact number',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),
              const FormSectionHeader(title: 'Room Type'),
              const SizedBox(height: 8),

              roomTypeState.status == RoomTypeStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : roomTypeState.status == RoomTypeStatus.error
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error loading room types: ${roomTypeState.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(typeViewmodelProvider.notifier).getAllTypes();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : roomTypeState.types.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'No room types available. Please check your Hive database.',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      )
                    : DropdownButtonFormField<RoomTypeEntity>(
                      initialValue: _selectedRoomType, 
                      isExpanded: true,
                      items: roomTypeState.types.map(
                        (type) => DropdownMenuItem<RoomTypeEntity>(
                          value: type,
                          child: Text(type.typeName),
                        ),
                      )
                      .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoomType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select room type',
                        border: OutlineInputBorder(),
                      ),
                    ),

              const SizedBox(height: 20),
              const FormSectionHeader(title: 'Description'),
              const SizedBox(height: 8),

              StyledTextField(
                controller: _descriptionController,
                hintText: 'Description',
                maxLines: 3,
              ),

              const SizedBox(height: 20),
              const FormSectionHeader(title: 'Media'),
              const SizedBox(height: 8),

              MediaUploadSection(
                selectedMedia: [..._localImageFiles, ..._localVideoFiles],
                remoteUrls: [..._imageUrls, ..._videoUrls],
                onAddMedia: _showMediaPicker,
                onRemoveMedia: (index) {
                  setState(() {
                    final totalImages = _localImageFiles.length;
                    if (index < totalImages) {
                      _localImageFiles.removeAt(index);
                      _imageUrls.removeAt(index);
                    } else {
                      _localVideoFiles.removeAt(index - totalImages);
                      _videoUrls.removeAt(index - totalImages);
                    }
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: MyButton(
                  onPressed: addRoomState.status == AddRoomStatus.loading ? null : _submit,
                  text: addRoomState.status == AddRoomStatus.loading
                      ? "Creating Room..."
                      : "Post Room",
                  color: AppColors.primary,
                  isLoading: addRoomState.status == AddRoomStatus.loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
