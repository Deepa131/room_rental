import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_extensions.dart';

class MyRoomCard extends StatelessWidget {
  final String title;
  final String location;
  final String roomType;
  final String status; // e.g., 'Available', 'Rented'
  final String? imageUrl;
  final String? price;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAvailability;

  const MyRoomCard({
    super.key,
    required this.title,
    required this.location,
    required this.roomType,
    required this.status,
    this.imageUrl,
    this.price,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleAvailability,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.foundColor;
      case 'rented':
        return AppColors.warning;
      case 'inactive':
        return AppColors.claimedColor;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'rented':
        return 'Rented';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInactive = status.toLowerCase() == 'inactive';

    return Opacity(
      opacity: isInactive ? 0.65 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.isDarkMode 
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  _buildMainContent(context),
                  if (!isInactive) ...[
                    const SizedBox(height: 14),
                    _buildActionButtons(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final isInactive = status.toLowerCase() == 'inactive';

    return Row(
      children: [
        _buildRoomImage(context, isInactive),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleRow(context),
              const SizedBox(height: 8),
              _buildLocationRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomImage(BuildContext context, bool isInactive) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: isInactive && imageUrl == null ? AppColors.claimedColor : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: 70,
              height: 70,
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.claimedColor.withOpacity(0.2),
                child: Icon(
                  Icons.house_rounded,
                  color: AppColors.claimedColor,
                  size: 32,
                ),
              ),
            )
          : Container(
              color: AppColors.claimedColor.withOpacity(0.15),
              child: Icon(
                Icons.house_rounded,
                color: AppColors.claimedColor,
                size: 32,
              ),
            ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);
    final isRented = status.toLowerCase() == 'rented';
    final isAvailable = status.toLowerCase() == 'available';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle_rounded
                : isRented
                    ? Icons.lock_rounded
                    : Icons.do_not_disturb_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 13,
          color: AppColors.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            '$location • $roomType',
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (price != null) ...[
          const SizedBox(width: 10),
          Text(
            '₹$price/mo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isAvailable = status.toLowerCase() == 'available';
    
    return Column(
      children: [
        Container(
          height: 0.8,
          color: context.isDarkMode 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
        ),
        const SizedBox(height: 14),
        // Toggle Availability Button - Premium Gradient Style
        _buildGradientButton(
          onTap: onToggleAvailability,
          icon: isAvailable ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
          label: isAvailable ? 'Mark as Rented' : 'Mark as Available',
          color: isAvailable ? AppColors.warning : AppColors.foundColor,
          context: context,
        ),
        const SizedBox(height: 12),
        // Edit and Delete Buttons - Modern Outlined Style
        Row(
          children: [
            Expanded(
              child: _buildOutlinedButton(
                onTap: onEdit,
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: AppColors.primary,
                context: context,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildOutlinedButton(
                onTap: onDelete,
                icon: Icons.delete_rounded,
                label: 'Delete',
                color: AppColors.error,
                context: context,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Color color,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: color.withOpacity(0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
