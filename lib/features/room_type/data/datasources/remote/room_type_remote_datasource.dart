import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_rental/core/api/api_client.dart';
import 'package:room_rental/core/api/api_endpoints.dart';
import 'package:room_rental/features/room_type/data/datasources/room_type_datasource.dart';
import 'package:room_rental/features/room_type/data/models/room_type_api_model.dart';
import 'package:room_rental/features/room_type/data/models/room_type_hive_model.dart';

// provider
final roomTypeRemoteProvider = Provider<IRoomTypeRemoteDataSource>((ref) {
  return RoomTypeRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class RoomTypeRemoteDatasource implements IRoomTypeRemoteDataSource {
  final ApiClient _apiClient;

  RoomTypeRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<bool> createType(RoomTypeHiveModel type) async {
    final response = await _apiClient.post(ApiEndpoints.types);
    return response.data['success'] == true;
  }

  @override
  Future<List<RoomTypeApiModel>> getAllTypes() async {
    final response = await _apiClient.get(ApiEndpoints.types);
    
    // Handle different response formats
    List dataList = [];
    
    if (response.data is Map) {
      if (response.data.containsKey('data')) {
        dataList = response.data['data'];
      } else {
        dataList = [];
      }
    } else if (response.data is List) {
      dataList = response.data;
    }

    // Convert to List<Map<String, dynamic>> and parse
    return (dataList as List).map((json) {
      if (json is Map<String, dynamic>) {
        return RoomTypeApiModel.fromJson(json);
      } else {
        return RoomTypeApiModel.fromJson(json as Map<String, dynamic>);
      }
    }).toList();
  }

  @override
  Future<RoomTypeApiModel?> getTypeById(String typeId) {
    // TODO: implement getBatchById
    throw UnimplementedError();
  }

  @override
  Future<bool> updateType(RoomTypeApiModel type) {
    // TODO: implement updateBatch
    throw UnimplementedError();
  }
}
