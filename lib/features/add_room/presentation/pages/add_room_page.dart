import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/core/utils/my_snackbar.dart';
import 'package:room_rental/core/utils/phone_validator.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/add_room/presentation/state/add_room_state.dart';
import 'package:room_rental/features/add_room/presentation/view_model/add_room_viewmodel.dart';
import 'package:room_rental/features/room_type/presentation/state/room_type_state.dart';
import 'package:room_rental/features/room_type/presentation/view_model/room_type_viewmodel.dart';
import '../../../room_type/domain/entities/room_type_entity.dart';
import '../../../../core/services/storage/location_service.dart';
import '../widgets/media_picker_bottom_sheet.dart';
import '../widgets/media_upload_section.dart';
import '../widgets/form_section_header.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/location_picker_widget.dart';

class AddRoomPage extends ConsumerStatefulWidget {
  final String? roomId;

  const AddRoomPage({super.key, this.roomId});

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
  LocationCoords? _selectedLocationCoords;
  final List<String> _imageUrls = [];
  final List<String> _videoUrls = [];
  final List<File?> _localImageFiles = [];
  final List<File?> _localVideoFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(typeViewmodelProvider.notifier).getAllTypes();
      if (widget.roomId != null) {
        ref.read(addRoomViewModelProvider.notifier).getRoomById(widget.roomId!);
      }
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
            "This feature requires permission to access your camera or microphone.",
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

  Future<void> _pickImage(ImageSource source) async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final file = await _picker.pickImage(source: source, imageQuality: 80);
    if (file == null) return;

    final imageFile = File(file.path);

    setState(() {
      _localImageFiles.add(imageFile);
      _imageUrls.add(
        '',
      ); 
    });

    final url = await ref.read(addRoomViewModelProvider.notifier).uploadRoomImage(imageFile);

    if (url != null) {
      setState(() {
        final index = _imageUrls.length - 1;
        _imageUrls[index] = url;
      });
    } else {
      setState(() {
        _localImageFiles.removeLast();
        _imageUrls.removeLast();
      });
    }
  }

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

    setState(() {
      _localVideoFiles.add(videoFile);
      _videoUrls.add(
        '',
      ); 
    });

    final url = await ref.read(addRoomViewModelProvider.notifier).uploadRoomVideo(videoFile);

    if (url != null) {
      setState(() {
        final index = _videoUrls.length - 1;
        _videoUrls[index] = url;
      });
    } else {
      setState(() {
        _localVideoFiles.removeLast();
        _videoUrls.removeLast();
      });
    }
  }

  void _showMediaPicker() {
    MediaPickerBottomSheet.show(
      context,
      onCameraTap: () => _pickImage(ImageSource.camera),
      onGalleryTap: () => _pickImage(ImageSource.gallery),
      onVideoTap: _pickVideo,
    );
  }
  void _populateFormFields(dynamic room) {
    setState(() {
      _titleController.text = room.roomTitle ?? '';
      _priceController.text = room.monthlyPrice?.toString() ?? '';
      _locationController.text = room.location ?? '';
      _contactController.text = room.ownerContactNumber ?? '';
      _descriptionController.text = room.description ?? '';
      _selectedRoomType = room.roomType;

      if (room.locationCoords != null) {
        final coords = room.locationCoords;
        _selectedLocationCoords = LocationCoords(
          latitude: coords.latitude,
          longitude: coords.longitude,
          address: coords.address ?? room.location,
        );
        _locationController.text =
            coords.address ?? room.location ?? _locationController.text;
      } else if (room.location != null && room.location.toString().isNotEmpty) {
        _selectedLocationCoords = LocationCoords(
          latitude: 27.7172,
          longitude: 85.324,
          address: room.location,
        );
        _locationController.text = room.location;
      }

      if (room.images != null && room.images!.isNotEmpty) {
        _imageUrls.clear();
        _imageUrls.addAll(room.images!);
        _localImageFiles
          ..clear()
          ..addAll(List<File?>.filled(_imageUrls.length, null));
      }

      if (room.videos != null && room.videos!.isNotEmpty) {
        _videoUrls.clear();
        _videoUrls.addAll(room.videos!);
        _localVideoFiles
          ..clear()
          ..addAll(List<File?>.filled(_videoUrls.length, null));
      }
    });
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

    String priceText = _priceController.text.trim();
    if (priceText.startsWith('Rs.')) {
      priceText = priceText.replaceFirst('Rs.', '').trim();
    }

    try {
      double.parse(priceText);
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

    if (ownerId == null || ownerId.isEmpty) {
      showMySnackBar(
        context: context,
        message: 'User not authenticated. Please login again.',
        color: Colors.red,
      );
      return;
    }
    _proceedWithRoomCreation();
  }

  Future<void> _proceedWithRoomCreation() async {
    final userSession = ref.read(userSessionServiceProvider);
    final ownerId = userSession.getUserId();

    if (ownerId == null || ownerId.isEmpty) {
      showMySnackBar(
        context: context,
        message: 'User not authenticated. Please login again.',
        color: Colors.red,
      );
      return;
    }

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

    final isEditMode = widget.roomId != null;

    if (isEditMode) {
      await ref.read(addRoomViewModelProvider.notifier).updateRoom(
        roomId: widget.roomId!,
        ownerId: ownerId,
        ownerContactNumber: _contactController.text.trim(),
        roomTitle: _titleController.text.trim(),
        monthlyPrice: monthlyPrice,
        location: _locationController.text.trim(),
        roomType: _selectedRoomType!,
        description: _descriptionController.text.trim(),
        images: _imageUrls,
        videos: _videoUrls,
        locationCoords: _selectedLocationCoords != null ? {
          'latitude': _selectedLocationCoords!.latitude,
          'longitude': _selectedLocationCoords!.longitude,
          'address': _selectedLocationCoords!.address,
        }
        : null,
      );
    } else {
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
        locationCoords: _selectedLocationCoords != null ? {
          'latitude': _selectedLocationCoords!.latitude,
          'longitude': _selectedLocationCoords!.longitude,
          'address': _selectedLocationCoords!.address,
        } : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addRoomState = ref.watch(addRoomViewModelProvider);
    final roomTypeState = ref.watch(typeViewmodelProvider);
    final isEditMode = widget.roomId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (roomTypeState.status == RoomTypeStatus.initial) {
        ref.read(typeViewmodelProvider.notifier).getAllTypes();
      }
      if (isEditMode &&
          addRoomState.selectedRoom != null &&
          _titleController.text.isEmpty) {
        _populateFormFields(addRoomState.selectedRoom!);
      }
    });

    final roomTypesById = <String, RoomTypeEntity>{};
    for (final type in roomTypeState.types) {
      if (type.typeId != null && !roomTypesById.containsKey(type.typeId)) {
        roomTypesById[type.typeId!] = type;
      }
    }
    final roomTypes = roomTypesById.values.toList();

    if (roomTypes.isNotEmpty) {
      if (_selectedRoomType == null) {
        _selectedRoomType = roomTypes.first;
      } else {
        final selectedId = _selectedRoomType!.typeId;
        final match = selectedId == null ? null : roomTypesById[selectedId];
        if (match != null) {
          _selectedRoomType = match;
        }
      }
    }

    ref.listen(addRoomViewModelProvider, (prev, next) {
      final wasJustCreated =
          (prev != null &&
          prev.status != AddRoomStatus.created &&
          next.status == AddRoomStatus.created);
      if (wasJustCreated) {
        showMySnackBar(context: context, message: 'Room added successfully!');
        if (!isEditMode) {
          _titleController.clear();
          _priceController.clear();
          _locationController.clear();
          _contactController.clear();
          _descriptionController.clear();
          _imageUrls.clear();
          _videoUrls.clear();
          _localImageFiles.clear();
          _localVideoFiles.clear();
        }
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.pop(context);
        });
      }

      final wasJustUpdated =
          (prev != null &&
          prev.status != AddRoomStatus.updated &&
          next.status == AddRoomStatus.updated);

      if (wasJustUpdated) {
        showMySnackBar(context: context, message: 'Room updated successfully!');
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) Navigator.pop(context);
        });
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.blue),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEditMode ? 'Edit Room' : 'Add New Room',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            color: Colors.white,
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormSectionHeader(title: 'Room Details'),
                  const SizedBox(height: 16),

                  StyledTextField(
                    controller: _titleController,
                    hintText: 'Room title',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  StyledTextField(
                    controller: _priceController,
                    hintText: 'Monthly price',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final price = double.tryParse(v);
                      if (price == null) return 'Invalid price';
                      if (price < 1000) return 'Price must be at least 1000';
                      if (price > 1000000) return 'Price cannot exceed 1000000';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  LocationPickerWidget(
                    onLocationSelect: (location, address) {
                      setState(() {
                        _selectedLocationCoords = location;
                        _locationController.text = address;
                      });
                    },
                    title: 'Room Location',
                    userId: ref.read(userSessionServiceProvider).getUserId(),
                    defaultLocation: _selectedLocationCoords,
                  ),
                  const SizedBox(height: 16),

                  StyledTextField(
                    controller: _contactController,
                    hintText: 'Contact number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      return PhoneValidator.validateNepalPhone(v);
                    },
                  ),

                  const SizedBox(height: 24),
                  const FormSectionHeader(title: 'Room Type'),
                  const SizedBox(height: 14),

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
                              MyButton(
                                onPressed: () {
                                  ref.read(typeViewmodelProvider.notifier).getAllTypes();
                                },
                                text: 'Retry',
                                color: Colors.red,
                              ),
                            ],
                          ),
                        )
                      : roomTypes.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'No room types available.',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        )
                      : DropdownButtonFormField<RoomTypeEntity>(
                          value: _selectedRoomType,
                          isExpanded: true,
                          items: roomTypes.map((type) {
                            return DropdownMenuItem<RoomTypeEntity>(
                              value: type,
                              child: Text(type.typeName),
                            );
                          }).toList(),
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

                  const SizedBox(height: 24),
                  const FormSectionHeader(title: 'Description'),
                  const SizedBox(height: 14),

                  StyledTextField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),
                  const FormSectionHeader(title: 'Media'),
                  const SizedBox(height: 14),

                  MediaUploadSection(
                    selectedMedia: [..._localImageFiles, ..._localVideoFiles],
                    remoteUrls: [..._imageUrls, ..._videoUrls],
                    onAddMedia: _showMediaPicker,
                    onRemoveMedia: (index) {
                      setState(() {
                        final totalImages = _imageUrls.length;
                        if (index < totalImages) {
                          if (index < _localImageFiles.length) {
                            _localImageFiles.removeAt(index);
                          }
                          _imageUrls.removeAt(index);
                        } else {
                          final videoIndex = index - totalImages;
                          if (videoIndex < _localVideoFiles.length) {
                            _localVideoFiles.removeAt(videoIndex);
                          }
                          _videoUrls.removeAt(index - totalImages);
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: MyButton(
                      onPressed: addRoomState.status == AddRoomStatus.loading
                          ? null
                          : _submit,
                      text: addRoomState.status == AddRoomStatus.loading
                          ? (isEditMode
                                ? "Updating Room..."
                                : "Creating Room...")
                          : (isEditMode ? "Update Room" : "Post Room"),
                      color: AppColors.primary,
                      isLoading: addRoomState.status == AddRoomStatus.loading,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
