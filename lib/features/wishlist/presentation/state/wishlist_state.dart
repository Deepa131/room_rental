import 'package:equatable/equatable.dart';
import 'package:room_rental/features/add_room/domain/entities/add_room_entity.dart';

class WishlistState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<AddRoomEntity> wishlistRooms;
  final Set<String> wishlistRoomIds;

  const WishlistState({
    required this.isLoading,
    this.error,
    required this.wishlistRooms,
    required this.wishlistRoomIds,
  });

  factory WishlistState.initial() {
    return const WishlistState(
      isLoading: false,
      error: null,
      wishlistRooms: [],
      wishlistRoomIds: {},
    );
  }

  WishlistState copyWith({
    bool? isLoading,
    String? error,
    List<AddRoomEntity>? wishlistRooms,
    Set<String>? wishlistRoomIds,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      wishlistRooms: wishlistRooms ?? this.wishlistRooms,
      wishlistRoomIds: wishlistRoomIds ?? this.wishlistRoomIds,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, wishlistRooms, wishlistRoomIds];
}
