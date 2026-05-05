import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/api_constants.dart';

class AgentService {
  static final Dio _dio = DioClient.instance;

  /// GET /agent-targets/
  static Future<List<dynamic>> getTargets() async {
    try {
      final response = await _dio.get(ApiConstants.agentTargets);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// GET /agents/
  static Future<List<dynamic>> list() async {
    try {
      final response = await _dio.get(ApiConstants.agents);
      final data = response.data;
      return data is List ? data : (data['results'] as List? ?? []);
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// POST /agents/
  static Future<Map<String, dynamic>> create({
    required String targetItem,
    required double maxBudget,
    String? requirementsPrompt,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.agents, data: {
        'target_item': targetItem,
        'max_budget': maxBudget,
        'requirements_prompt': requirementsPrompt,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// PATCH /agents/{id}/
  static Future<Map<String, dynamic>> update(
      int id, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.patch(ApiConstants.agentDetail(id), data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }

  /// DELETE /agents/{id}/
  static Future<void> delete(int id) async {
    try {
      await _dio.delete(ApiConstants.agentDetail(id));
    } on DioException catch (e) {
      throw Exception(parseDioError(e));
    }
  }
}
