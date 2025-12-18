import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/navigation.dart';
import '../../features/auth/presentation/views/login_view.dart';

class ApiClient {
  static const String _baseUrl = 'https://api-panda.studyfoc.us';

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = _getToken();
    if (token == null) {
      _redirectToLogin();
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final token = _getToken();
    if (token == null) {
      _redirectToLogin();
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static String? _getToken() {
    return Supabase.instance.client.auth.currentSession?.accessToken;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      _redirectToLogin();
      throw Exception('Unauthorized');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }

  static void _redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }
}
