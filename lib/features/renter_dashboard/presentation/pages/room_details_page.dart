import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/core/widgets/my_button.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';
import 'package:room_rental/features/wishlist/presentation/view_model/wishlist_view_model.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/appointment/presentation/pages/book_appointment_page.dart';
import 'package:room_rental/features/appointment/presentation/view_model/appointment_viewmodel.dart';
import 'package:room_rental/core/services/storage/location_service.dart';
import '../widgets/route_display_widget.dart';
import '../widgets/navigation_container.dart';

class RoomDetailsPage extends ConsumerStatefulWidget {
  final AddRoomEntity room;

  const RoomDetailsPage({super.key, required this.room});

  @override
  ConsumerState<RoomDetailsPage> createState() => _RoomDetailsPageState();
}

class _RoomDetailsPageState extends ConsumerState<RoomDetailsPage> {
  int _currentMediaIndex = 0;
  late PageController _pageController;
  late List<MediaItem> _mediaItems;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildMediaItems();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userSession = ref.read(userSessionServiceProvider);
      final userId = userSession.getUserId();
      if (userId != null && userId.isNotEmpty) {
        ref.read(appointmentViewModelProvider.notifier).getMyAppointments(userId);
      }
    });
  }

  void _buildMediaItems() {
    _mediaItems = [];
    
    // Add images
    if (widget.room.images != null) {
      for (final image in widget.room.images!) {
        _mediaItems.add(MediaItem(
          type: MediaType.image,
          url: ImageUrlHelper.getImageUrl(image),
          filename: image,
        ));
      }
    }
    
    // Add videos
    if (widget.room.videos != null) {
      for (final video in widget.room.videos!) {
        final videoUrl = ImageUrlHelper.getImageUrl(video);
        _mediaItems.add(MediaItem(
          type: MediaType.video,
          url: videoUrl,
          filename: video,
        ));
      }
    }
  }

  void _showNavigationModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Navigation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.room.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Navigation Container
            Flexible(
              child: FutureBuilder<LocationCoords?>(
                future: LocationService.getCachedUserLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  final cachedLocation = snapshot.data;
                  if (cachedLocation != null) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: NavigationContainer(
                          userLocation: cachedLocation,
                          roomLocation: LocationCoords(
                            latitude: widget.room.locationCoords!.latitude,
                            longitude: widget.room.locationCoords!.longitude,
                            address: widget.room.location,
                          ),
                          roomAddress: widget.room.location,
                        ),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Please enable location to use navigation',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBookAppointment() {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    
    final appointments = ref.read(appointmentViewModelProvider).appointments;
    final hasExistingAppointment = appointments.any(
      (apt) => 
        apt.roomId == widget.room.roomId && 
        apt.renterId == userId &&
        (apt.status == 'pending' || apt.status == 'approved'),
    );

    if (hasExistingAppointment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already have an appointment for this room. Check your Appointments tab.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookAppointmentPage(room: widget.room),
      ),
    );
  }

  bool _hasExistingAppointment() {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    
    if (userId == null) return false;
    
    final appointments = ref.read(appointmentViewModelProvider).appointments;
    return appointments.any(
      (apt) => 
        apt.roomId == widget.room.roomId && 
        apt.renterId == userId &&
        (apt.status == 'pending' || apt.status == 'approved'),
    );
  }

  String _getAppointmentButtonLabel() {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    
    if (userId == null) return 'Book Appointment';
    
    final appointments = ref.read(appointmentViewModelProvider).appointments;
    final appointment = appointments.where(
      (apt) => 
        apt.roomId == widget.room.roomId && 
        apt.renterId == userId &&
        (apt.status == 'pending' || apt.status == 'approved' || apt.status == 'rejected'),
    ).firstOrNull;

    if (appointment == null) {
      return 'Book Appointment';
    }

    switch (appointment.status.toLowerCase()) {
      case 'pending':
        return 'Appointment Pending';
      case 'approved':
        return 'Appointment Approved';
      case 'rejected':
        return 'Book Appointment';
      default:
        return 'Book Appointment';
    }
  }

  Color _getAppointmentButtonColor(bool hasExisting) {
    if (!hasExisting) {
      return AppColors.primary;
    }

    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    
    if (userId == null) return AppColors.primary;
    
    final appointments = ref.read(appointmentViewModelProvider).appointments;
    final appointment = appointments.where(
      (apt) => 
        apt.roomId == widget.room.roomId && 
        apt.renterId == userId &&
        (apt.status == 'pending' || apt.status == 'approved' || apt.status == 'rejected'),
    ).firstOrNull;

    if (appointment == null) {
      return AppColors.primary;
    }

    switch (appointment.status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return Colors.green;
      case 'approved':
        return AppColors.foundColor;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    final wishlistState = ref.watch(wishlistViewModelProvider);
    final roomId = widget.room.roomId ?? '';
    final isInWishlist = wishlistState.wishlistRoomIds.contains(roomId);

    return Scaffold(
      backgroundColor: context.backgroundColor,
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
        title: const Text(
          'Room Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          if (userId != null && userId.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  isInWishlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isInWishlist ? Colors.amber : Colors.blue,
                  size: 24,
                ),
                onPressed: () async {
                  if (roomId.isNotEmpty) {
                    final isCurrentlyInWishlist = isInWishlist;
                    await ref
                        .read(wishlistViewModelProvider.notifier)
                        .toggleWishlist(userId, roomId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCurrentlyInWishlist 
                              ? 'Removed from wishlist' 
                              : 'Added to wishlist'
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.blue.shade600],
                ),
              ),
            ),
          ),
          // Main Content
          SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Carousel
            _buildMediaCarousel(),

            // Room Info Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.room.roomTitle,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.room.isAvailable
                                ? AppColors.foundColor.withAlpha(26)
                                : AppColors.warning.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.room.isAvailable ? 'Available' : 'Rented',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.room.isAvailable
                                  ? AppColors.foundColor
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.room.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Route Display Widget
                    if (widget.room.locationCoords != null)
                      RouteDisplayWidget(
                        roomLocation: LocationCoords(
                          latitude: widget.room.locationCoords!.latitude,
                          longitude: widget.room.locationCoords!.longitude,
                          address: widget.room.location,
                        ),
                        roomAddress: widget.room.location,
                        userId: ref.read(userSessionServiceProvider).getUserId(),
                        onShowNavigation: _showNavigationModal,
                      ),
                    if (widget.room.locationCoords != null)
                      const SizedBox(height: 12),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primary.withAlpha(204)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'NPR',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Text(
                                '${widget.room.monthlyPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '/month',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                    const SizedBox(height: 16),

                    // Room Details Grid
                    _buildDetailsGrid(),
                    const SizedBox(height: 16),

                    // Description
                    if (widget.room.description != null &&
                        widget.room.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About This Room',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.room.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Contact Owner Section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(13),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Owner',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withAlpha(204)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Room Owner',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondary,
                              ),
                            ),
                            subtitle: Text(
                              widget.room.ownerName ?? 'Owner',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Icon(
                                Icons.phone,
                                color: Colors.green[700],
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondary,
                              ),
                            ),
                            subtitle: Text(
                              widget.room.ownerContactNumber,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final appointmentState = ref.watch(appointmentViewModelProvider);
                              final hasExisting = _hasExistingAppointment();
                              final buttonLabel = _getAppointmentButtonLabel();
                              final buttonColor = _getAppointmentButtonColor(hasExisting);
                              final isRejected = buttonLabel == 'Book Appointment' && hasExisting;
                              
                              return MyIconButton(
                                onPressed: hasExisting && !isRejected ? null : _handleBookAppointment,
                                text: buttonLabel,
                                icon: isRejected
                                    ? Icons.calendar_today_rounded
                                    : hasExisting
                                        ? Icons.check_circle_rounded 
                                        : Icons.calendar_today_rounded,
                                backgroundColor: hasExisting && !isRejected
                                    ? buttonColor.withOpacity(0.6)
                                    : buttonColor,
                                foregroundColor: hasExisting && !isRejected
                                    ? Colors.grey
                                    : Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    if (_mediaItems.isEmpty) {
      return Container(
        height: 350,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Main Media Display
        SizedBox(
          height: 350,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentMediaIndex = index);
                },
                itemCount: _mediaItems.length,
                itemBuilder: (context, index) {
                  final media = _mediaItems[index];
                  
                  if (media.type == MediaType.video) {
                    return _InlineVideoPlayer(videoUrl: media.url);
                  }
                  
                  return CachedNetworkImage(
                    imageUrl: media.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),

              // Full-screen Button
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(153),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
                    onPressed: () => _showFullScreenMedia(_mediaItems[_currentMediaIndex]),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),

              // Media Counter
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(204),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentMediaIndex + 1}/${_mediaItems.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenMedia(MediaItem media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenMediaViewer(
          media: media,
          allMedia: _mediaItems,
          initialIndex: _currentMediaIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.home_outlined,
            label: 'Type',
            value: widget.room.roomType.typeName,
          ),
          Container(
            width: 1,
            height: 40,
            color: context.dividerColor,
          ),
          _buildDetailItem(
            icon: Icons.check_circle_outline,
            label: 'Status',
            value: widget.room.isAvailable ? 'Available' : 'Occupied',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

enum MediaType { image, video }

class MediaItem {
  final MediaType type;
  final String url;
  final String filename;

  MediaItem({
    required this.type,
    required this.url,
    required this.filename,
  });
}

class _InlineVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _InlineVideoPlayer({required this.videoUrl});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      _controller.addListener(() {
        setState(() {});
      });
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _seekRelative(int seconds) {
    final newPosition = _controller.value.position + Duration(seconds: seconds);
    final duration = _controller.value.duration;
    if (newPosition < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (newPosition > duration) {
      _controller.seekTo(duration);
    } else {
      _controller.seekTo(newPosition);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${minutes}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Failed to load video',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'URL: ${widget.videoUrl}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
            // Video controls overlay
            if (_showControls)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(102),
                      Colors.transparent,
                      Colors.black.withAlpha(102),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.videocam, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Room Video',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        children: [
                          // Progress bar
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: AppColors.primary,
                              bufferedColor: Colors.white30,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Time info and controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Rewind 10s
                                    GestureDetector(
                                      onTap: () => _seekRelative(-10),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.replay_10,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Play/Pause
                                    GestureDetector(
                                      onTap: _togglePlayPause,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(
                                          _controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Forward 10s
                                    GestureDetector(
                                      onTap: () => _seekRelative(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: const Icon(
                                          Icons.forward_10,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!_showControls && !_controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _FullScreenMediaViewer extends StatefulWidget {
  final MediaItem media;
  final List<MediaItem> allMedia;
  final int initialIndex;

  const _FullScreenMediaViewer({
    required this.media,
    required this.allMedia,
    required this.initialIndex,
  });

  @override
  State<_FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<_FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1}/${widget.allMedia.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: widget.allMedia.length,
        itemBuilder: (context, index) {
          final media = widget.allMedia[index];

          if (media.type == MediaType.video) {
            return _FullScreenVideoPlayer(videoUrl: media.url);
          }

          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: CachedNetworkImage(
                imageUrl: media.url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _FullScreenVideoPlayer({required this.videoUrl});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      _controller.addListener(() {
        setState(() {});
      });
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _seekRelative(int seconds) {
    final newPosition = _controller.value.position + Duration(seconds: seconds);
    _controller.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading video',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(128),
                      Colors.transparent,
                      Colors.black.withAlpha(128),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top controls
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom controls
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _controller.value.duration.inMilliseconds > 0
                                  ? _controller.value.position.inMilliseconds /
                                      _controller.value.duration.inMilliseconds
                                  : 0,
                              backgroundColor: Colors.white.withAlpha(77),
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Playback controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _seekRelative(-10),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.replay_10,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _seekRelative(10),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.forward_10,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_showControls && !_controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
          ],
        ),
      ),
    );
  }
}