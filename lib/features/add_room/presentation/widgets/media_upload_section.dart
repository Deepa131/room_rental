import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';

class MediaUploadSection extends StatelessWidget {
  final List<File?> selectedMedia;
  final List<String> remoteUrls;
  final VoidCallback onAddMedia;
  final Function(int) onRemoveMedia;

  const MediaUploadSection({
    super.key,
    required this.selectedMedia,
    required this.remoteUrls,
    required this.onAddMedia,
    required this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Room Photos / Videos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AddMediaButton(
                onTap: onAddMedia,
              ),
              if (selectedMedia.isNotEmpty)
                ...List.generate(
                  selectedMedia.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _MediaPreview(
                      file: selectedMedia[index],
                      remoteUrl: remoteUrls[index],
                      onRemove: () => onRemoveMedia(index),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMediaButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.surfaceColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_a_photo_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo / Video',
              style: TextStyle(
                fontSize: 11,
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPreview extends StatefulWidget {
  final File? file;
  final String remoteUrl;
  final VoidCallback onRemove;

  const _MediaPreview({
    required this.file,
    required this.remoteUrl,
    required this.onRemove,
  });

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    if (_isVideo()) {
      _thumbnailFuture = _generateThumbnail();
    }
  }

  bool _isVideo() {
    if (widget.file != null) {
      final extension = widget.file!.path.toLowerCase().split('.').last;
      return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(extension);
    }
    if (widget.remoteUrl.isNotEmpty) {
      return widget.remoteUrl.toLowerCase().contains('.mp4') ||
          widget.remoteUrl.toLowerCase().contains('.mov') ||
          widget.remoteUrl.toLowerCase().contains('.avi') ||
          widget.remoteUrl.toLowerCase().contains('.mkv');
    }
    return false;
  }

  Future<Uint8List?> _generateThumbnail() async {
    try {
      if (widget.file != null) {
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: widget.file!.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 120,
          maxWidth: 120,
          timeMs: 0,
        );
        return thumbnail;
      }
    } catch (e) {
      print('Error generating thumbnail: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideo();

    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[300],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: isVideo
                ? FutureBuilder<Uint8List?>(
                    future: _thumbnailFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      } else {
                        return Container(
                          color: Colors.grey[400],
                          child: Center(
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        );
                      }
                    },
                  )
                : widget.file != null
                    ? Image.file(
                        widget.file!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : widget.remoteUrl.isNotEmpty
                        ? Image.network(
                            widget.remoteUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
          ),
        ),
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
