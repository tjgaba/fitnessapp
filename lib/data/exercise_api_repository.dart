import 'package:dio/dio.dart';

import 'models/api_exercise.dart';

class ExerciseApiRepository {
  static const String _baseUrl = 'https://api.api-ninjas.com/v1/exercises';
  static const String _apiKey = '2fqUK0OjK3e2uOiwiHDvCDIRidHv8gSrvVsm6P6T';

  final Dio _dio = Dio();

  Future<List<ApiExercise>> searchExercises({
    required String type,
    String? muscle,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'type': type};
      final normalizedMuscle = (muscle ?? '').trim();
      if (normalizedMuscle.isNotEmpty) {
        queryParameters['muscle'] = normalizedMuscle;
      }

      final response = await _dio.get<dynamic>(
        _baseUrl,
        queryParameters: queryParameters,
        options: Options(
          headers: {'X-Api-Key': _apiKey},
        ),
      );

      final data = response.data;
      if (data is! List) {
        throw Exception('Failed to load exercises: malformed response data.');
      }

      return data
          .whereType<Map>()
          .map(
            (item) => ApiExercise.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Check your internet.');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Check your API Ninjas key.');
      }

      if (e.response?.statusCode == 429) {
        throw Exception('Rate limit exceeded. Wait a moment and try again.');
      }

      if (e.response != null) {
        throw Exception('Server error: ${e.response?.statusCode}');
      }

      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }
}
