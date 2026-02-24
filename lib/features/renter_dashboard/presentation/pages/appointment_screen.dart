import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:room_rental/app/theme/app_colors.dart';
import 'package:room_rental/app/theme/theme_extensions.dart';
import 'package:room_rental/core/utils/image_url_helper.dart';
import 'package:room_rental/core/services/storage/user_session_service.dart';
import 'package:room_rental/features/appointment/presentation/view_model/appointment_viewmodel.dart';
import 'package:room_rental/features/appointment/presentation/state/appointment_state.dart';
import 'package:room_rental/features/appointment/domain/entities/appointment_entity.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  void _loadAppointments() {
    final userSession = ref.read(userSessionServiceProvider);
    final userId = userSession.getUserId();
    if (userId != null && userId.isNotEmpty) {
      ref.read(appointmentViewModelProvider.notifier).getMyAppointments(userId);
    }
  }

  void _deleteAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(appointmentViewModelProvider.notifier).cancelAppointment(appointmentId);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadAppointments();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete appointment'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editAppointment(AppointmentEntity appointment) {
    
    final localAppointmentDate = appointment.appointmentDate.toLocal();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(localAppointmentDate),
    );
    final timeController = TextEditingController(
      text: _normalizeTimeTo12h(appointment.appointmentTime),
    );
    final messageController = TextEditingController(text: appointment.message ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  hintText: 'YYYY-MM-DD',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); 
                  final today = DateTime.now();
                  final initialDate = localAppointmentDate.isAfter(today)
                      ? localAppointmentDate
                      : today;
                  final date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: today,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'HH:MM AM/PM',
                  prefixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      final mediaQuery = MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                      );
                      return MediaQuery(
                        data: mediaQuery,
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    timeController.text = _formatTimeOfDay(time);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Any special requirements...',
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final dateParts = dateController.text.split('-');
              DateTime newDate;
              if (dateParts.length == 3) {
                newDate = DateTime.utc(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                );
              } else {
                newDate = DateTime.parse(dateController.text).toUtc();
              }
              final success = await ref.read(appointmentViewModelProvider.notifier).updateAppointment(
                appointment.appointmentId!,
                newDate,
                timeController.text,
                messageController.text,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment updated successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (mounted) {
                final errorMessage = ref.read(appointmentViewModelProvider).error ?? 'Failed to update appointment';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final dateTime = DateTime(0, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }

  String _normalizeTimeTo12h(String timeText) {
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
        return const Color(0xFFFFC107);
      case 'approved':
        return const Color(0xFF8BC34A); 
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentViewModelProvider);
    final isLoading = appointmentState.status == AppointmentStatus.loading;
    final appointments = appointmentState.appointments;

    return RefreshIndicator(
      onRefresh: () async {
        _loadAppointments();
      },
      color: Colors.blue,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Appointments',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track your room viewing schedules',
                          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.85)),
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
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(color: Colors.blue),
                          const SizedBox(height: 12),
                          Text(
                            'Loading appointments...',
                            style: TextStyle(color: context.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : appointments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text(
                                'No appointments yet',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Book a room to schedule viewing',
                                style: TextStyle(fontSize: 12, color: context.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : null,
            ),
          ),
          if (!isLoading && appointments.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final appointment = appointments[index];
                    return _AppointmentCard(
                      appointment: appointment,
                      onEdit: () => _editAppointment(appointment),
                      onDelete: () => _deleteAppointment(appointment.appointmentId!),
                      formatDate: _formatDate,
                      getStatusColor: _getStatusColor,
                      capitalizeStatus: _capitalizeStatus,
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

class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;
  final Color Function(String) getStatusColor;
  final String Function(String) capitalizeStatus;

  const _AppointmentCard({
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    required this.getStatusColor,
    required this.capitalizeStatus,
  });

  @override
  Widget build(BuildContext context) {
    // For now, we'll use room data if available from backend
    final roomImage = appointment.room?.images?.isNotEmpty == true
        ? ImageUrlHelper.getImageUrl(appointment.room!.images!.first)
        : null;
    final roomTitle = appointment.room?.roomTitle ?? 'Room Appointment';
    final statusText = appointment.status.toLowerCase();
    final showDecisionActions = statusText == 'approved' || statusText == 'rejected';
    final showPendingActions = statusText == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: roomImage != null
                        ? CachedNetworkImage(
                            imageUrl: roomImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.meeting_room,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(
                            Icons.meeting_room,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Appointment Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(appointment.appointmentDate),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.appointmentTime,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (showPendingActions) ...[
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onEdit,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue.shade600, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.blue[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red.shade600, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (showDecisionActions)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onDelete,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade600, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Remove',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
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
          // Status Badge (Positioned at top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor(appointment.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                capitalizeStatus(appointment.status),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}