import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:rumour/models/user_id_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class IdentityRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://randomuser.me',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _uuid = const Uuid();

  Future<UserIdModel> getOrCreateIdentity(String roomCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'identity_$roomCode';
    final existing = prefs.getString(key);

    if (existing != null) {
      return UserIdModel.fromJson(jsonDecode(existing));
    }

    return await _createNewIdentity(roomCode, prefs, key);
  }

  Future<UserIdModel> _createNewIdentity(
    String roomCode,
    SharedPreferences prefs,
    String key,
  ) async {
    try {
      final response = await _dio.get('/api/');

      if (response.statusCode == 200) {
        final result = response.data['results'][0];

        final identity = UserIdModel(
          userId: _uuid.v4(),
          name: '${result['name']['first']} ${result['name']['last']}',
          avatarUrl: result['picture']['thumbnail'],
        );

        await prefs.setString(key, jsonEncode(identity.toJson()));
        return identity;
      } else {
        return _fallbackIdentity(roomCode, prefs, key);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out. Check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        return _fallbackIdentity(roomCode, prefs, key);
      }
      return _fallbackIdentity(roomCode, prefs, key);
    } catch (e) {
      return _fallbackIdentity(roomCode, prefs, key);
    }
  }

  UserIdModel _fallbackIdentity(
    String roomCode,
    SharedPreferences prefs,
    String key,
  ) {
    final identity = UserIdModel(
      userId: _uuid.v4(),
      name: 'Anonymous ${roomCode.substring(0, 2).toUpperCase()}',
      avatarUrl: '',
    );
    prefs.setString(key, jsonEncode(identity.toJson()));
    return identity;
  }

  Future<bool> hasJoinedRoom(String roomCode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('identity_$roomCode');
  }

  Future<void> saveRecentRoom(String roomCode) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'recent_rooms';
    final existing = prefs.getStringList(key) ?? [];

    if (!existing.contains(roomCode)) {
      existing.insert(0, roomCode);
    } else {
      existing.remove(roomCode);
      existing.insert(0, roomCode);
    }

    final trimmed = existing.take(10).toList();
    await prefs.setStringList(key, trimmed);
  }

  Future<List<String>> getRecentRooms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_rooms') ?? [];
  }
}
