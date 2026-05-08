import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiResult {
  const AuthApiResult({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  final bool success;
  final String message;
  final int statusCode;
  final Map<String, dynamic>? data;
}

class AuthApiService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';

  Future<AuthApiResult> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _post(
      path: '/register',
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) {
    return _post(path: '/login', body: {'email': email, 'password': password});
  }

  Future<AuthApiResult> getMe({required String token}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final decoded = _decodeJson(response.body);
      final success = decoded['success'] == true;
      final message =
          (decoded['message'] as String?) ??
          (success ? 'Thành công' : 'Yêu cầu thất bại');
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : null;

      return AuthApiResult(
        success: success,
        message: message,
        statusCode: response.statusCode,
        data: data,
      );
    } catch (_) {
      return const AuthApiResult(
        success: false,
        message: 'Không thể kết nối backend. Hãy kiểm tra server Node.js.',
        statusCode: 0,
      );
    }
  }

  Future<AuthApiResult> _post({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = _decodeJson(response.body);
      final success = decoded['success'] == true;
      final message =
          (decoded['message'] as String?) ??
          (success ? 'Thành công' : 'Yêu cầu thất bại');
      final data = decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : null;

      return AuthApiResult(
        success: success,
        message: message,
        statusCode: response.statusCode,
        data: data,
      );
    } catch (_) {
      return const AuthApiResult(
        success: false,
        message: 'Không thể kết nối backend. Hãy kiểm tra server Node.js.',
        statusCode: 0,
      );
    }
  }

  Map<String, dynamic> _decodeJson(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
