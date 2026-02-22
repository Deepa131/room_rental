class AppointmentEntity {
  final String? appointmentId;
  final String roomId;
  final String ownerId;
  final String renterId;
  final String renterName;
  final String renterEmail;
  final String renterPhone;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String? message;
  final String status; 
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RoomData? room;

  AppointmentEntity({
    this.appointmentId,
    required this.roomId,
    required this.ownerId,
    required this.renterId,
    required this.renterName,
    required this.renterEmail,
    required this.renterPhone,
    required this.appointmentDate,
    required this.appointmentTime,
    this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.room,
  });

  AppointmentEntity copyWith({
    String? appointmentId,
    String? roomId,
    String? ownerId,
    String? renterId,
    String? renterName,
    String? renterEmail,
    String? renterPhone,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    RoomData? room,
  }) {
    return AppointmentEntity(
      appointmentId: appointmentId ?? this.appointmentId,
      roomId: roomId ?? this.roomId,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      renterName: renterName ?? this.renterName,
      renterEmail: renterEmail ?? this.renterEmail,
      renterPhone: renterPhone ?? this.renterPhone,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      room: room ?? this.room,
    );
  }
}

class RoomData {
  final String? id;
  final String roomTitle;
  final String? location;
  final double? monthlyPrice;
  final List<String>? images;

  RoomData({
    this.id,
    required this.roomTitle,
    this.location,
    this.monthlyPrice,
    this.images,
  });
}
