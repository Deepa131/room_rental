import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/api/api_client.dart';
import 'package:room_rental/core/api/api_endpoints.dart';
import 'package:room_rental/core/services/storage/token_service.dart';
import 'package:room_rental/features/add_room/data/datasources/add_room_datasource.dart';
import 'package:room_rental/features/add_room/data/models/add_room_api_model.dart';

final addRoomRemoteDatasourceProvider =
    Provider<IAddRoomRemoteDataSource>((ref) {
  return AddRoomRemoteDatasource(
    apiClient: ref.watch(apiClientProvider),
  );
});

class AddRoomRemoteDatasource implements IAddRoomRemoteDataSource {
  final ApiClient _apiClient;
  late final TokenService _tokenService;

  AddRoomRemoteDatasource({
    required ApiClient apiClient,
  })  : _apiClient = apiClient {
    _tokenService = TokenService();
  }

  @override
  Future<String> uploadRoomImage(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'images': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadRoomImage,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'];
  }

  @override
  Future<String> uploadRoomVideo(File video) async {
    final fileName = video.path.split('/').last;
    final formData = FormData.fromMap({
      'videos': await MultipartFile.fromFile(video.path, filename: fileName),
    });

    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadRoomVideo,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'];
  }

  @override
  Future<AddRoomApiModel> createRoom(AddRoomApiModel room) async {
    final token = await _tokenService.getToken();

    final response = await _apiClient.post(
      ApiEndpoints.rooms,
      data: room.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return AddRoomApiModel.fromJson(response.data['data']);
  }

  @override
  Future<List<AddRoomApiModel>> getAllRooms() async {
    final response = await _apiClient.get(ApiEndpoints.rooms);
    final data = response.data['data'] as List;

    return data.map((json) => AddRoomApiModel.fromJson(json)).toList();
  }

  @override
  Future<AddRoomApiModel> getRoomById(String roomId) async {
    final response = await _apiClient.get(ApiEndpoints.roomById(roomId));
    return AddRoomApiModel.fromJson(response.data['data']);
  }

  @override
  Future<List<AddRoomApiModel>> getRoomsByOwner(String ownerId) async {
    final response = await _apiClient.get(
      ApiEndpoints.rooms,
      queryParameters: {'ownerId': ownerId},
    );

    final data = response.data['data'] as List;
    return data.map((json) => AddRoomApiModel.fromJson(json)).toList();
  }

  @override
  Future<bool> updateRoom(AddRoomApiModel room) async {
    final token = await _tokenService.getToken();

    await _apiClient.put(
      ApiEndpoints.roomById(room.id!),
      data: room.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return true;
  }

  @override
  Future<bool> deleteRoom(String roomId) async {
    final token = await _tokenService.getToken();

    await _apiClient.delete(
      ApiEndpoints.roomById(roomId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return true;
  }
}
