import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';
import 'package:room_rental/features/appointment/presentation/state/appointment_state.dart';
import 'package:room_rental/features/appointment/presentation/view_model/appointment_viewmodel.dart';

class OwnerRequestScreen extends ConsumerStatefulWidget {
  const OwnerRequestScreen({super.key});

  @override
  ConsumerState<OwnerRequestScreen> createState() => _OwnerRequestScreenState();
}

class _OwnerRequestScreenState extends ConsumerState<OwnerRequestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOwnerRequests();
    });
  }

  void _loadOwnerRequests() {
    final userSession = ref.read(userSessionServiceProvider);
    final ownerId = userSession.getUserId();
    if (ownerId != null && ownerId.isNotEmpty) {
      ref.read(appointmentViewModelProvider.notifier).getOwnerAppointments(ownerId);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(String timeText) {
    if (timeText.toLowerCase().contains('am') ||
        timeText.toLowerCase().contains('pm')) {
      return timeText;
    }

    try {
      final parts = timeText.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final dateTime = DateTime(0, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dateTime);
      }
    } catch (_) {
      return timeText;
    }

    return timeText;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.appointmentPending;
      case 'approved':
        return AppColors.appointmentApproved;
      case 'rejected':
        return AppColors.appointmentRejected;
      default:
        return AppColors.textTertiary;
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }

  bool _isDecisionMade(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'approved' || normalized == 'rejected';
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    final success = await ref.read(appointmentViewModelProvider.notifier).updateAppointmentStatus(appointmentId, status);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(appointmentViewModelProvider).error ?? 'Failed to update appointment';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _removeRequest(String appointmentId) async {
    final success = await ref.read(appointmentViewModelProvider.notifier).cancelAppointment(appointmentId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request removed successfully'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final errorMessage = ref.read(appointmentViewModelProvider).error ?? 'Failed to remove request';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetails(AppointmentEntity appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appointment Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Renter Name', appointment.renterName),
              _detailRow('Email', appointment.renterEmail),
              _detailRow('Phone', appointment.renterPhone),
              _detailRow('Date', _formatDate(appointment.appointmentDate)),
              _detailRow('Time', _formatTime(appointment.appointmentTime)),
              _detailRow('Message', appointment.message ?? '-'),
              _detailRow('Status', _capitalizeStatus(appointment.status)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentViewModelProvider);
    final isLoading = appointmentState.status == AppointmentStatus.loading;
    final appointments = appointmentState.appointments;

    return RefreshIndicator(
      onRefresh: () async {
        _loadOwnerRequests();
      },
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryLight, AppColors.primary],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment Requests',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white90,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage viewing appointments',
                          style: TextStyle(fontSize: 18, color: AppColors.white80),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: isLoading ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Loading requests...',
                      style: TextStyle(
                        color: context.textSecondary, fontSize: 13
                      ),
                    ),
                  ],
                ),
              ) : appointments.isEmpty ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'No requests yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requests will appear here once renters book',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary
                      ),
                    ),
                  ],
                ),
              ) : null,
            ),
          ),
          if (!isLoading && appointments.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final appointment = appointments[index];
                    return _OwnerRequestCard(
                      appointment: appointment,
                      formatDate: _formatDate,
                      formatTime: _formatTime,
                      statusColor: _getStatusColor(appointment.status),
                      statusText: _capitalizeStatus(appointment.status),
                      onView: () => _showDetails(appointment),
                      onApprove: appointment.status.toLowerCase() == 'pending'
                          ? () => _updateStatus(
                              appointment.appointmentId!, 'approved')
                          : null,
                      onReject: appointment.status.toLowerCase() == 'pending'
                          ? () => _updateStatus(
                              appointment.appointmentId!, 'rejected')
                          : null,
                      onRemove: _isDecisionMade(appointment.status)
                          ? () =>
                              _removeRequest(appointment.appointmentId!)
                          : null,
                    );
                  },
                  childCount: appointments.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnerRequestCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final String Function(DateTime) formatDate;
  final String Function(String) formatTime;
  final Color statusColor;
  final String statusText;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;

  const _OwnerRequestCard({
    required this.appointment,
    required this.formatDate,
    required this.formatTime,
    required this.statusColor,
    required this.statusText,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black20,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Icon(Icons.person, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.renterName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatDate(appointment.appointmentDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatTime(appointment.appointmentTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onView,
                          icon: const Icon(Icons.visibility, size: 12),
                          label: const Text('View', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 3),
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                color: AppColors.primary, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (onApprove != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon:
                                const Icon(Icons.check, size: 12),
                            label: const Text('Approve', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 3),
                              backgroundColor: AppColors.success,
                              foregroundColor: AppColors.surface,
                            ),
                          ),
                        ),
                      if (onReject != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.clear, size: 12),
                            label: const Text('Reject', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 3),
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                      if (onRemove != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete, size: 14),
                            label: const Text('Remove'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                                foregroundColor: AppColors.error,
                                side: const BorderSide(
                                  color: AppColors.error, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
