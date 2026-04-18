// lib/services/verification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart'; // Add this at the top with other imports

class VerificationService {
  // ⚠️ Automatically point to standard localhosts:
  static const String _baseUrl = kIsWeb 
      ? 'http://localhost:5000' 
      : 'http://10.0.2.2:5000';

  final _storage = const FlutterSecureStorage();

  // ── Save & retrieve JWT ──────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // ── Register Speaker & receive JWT ──────────────────────────────────────
  // Calls your existing registration endpoint.
  // Adjust the endpoint + request body to match YOUR backend exactly.
  Future<String> registerSpeaker({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),  // ← your existing endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
        'role': 'Speaker',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String; // ← match your response field
      await saveToken(token);
      return token;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Registration failed. Please retry.');
    }
  }

  // ── Create Persona Inquiry ───────────────────────────────────────────────
  // Calls POST /api/verification/create-inquiry with JWT
  Future<String> createInquiry() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/verification/create-inquiry'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['inquiryId'] as String;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Could not start liveness session.');
    }
  }

  // ── Poll verification status ─────────────────────────────────────────────
  // Calls GET /api/verification/status after SDK completes
  Future<Map<String, dynamic>> getVerificationStatus() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated.');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/verification/status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Could not fetch verification status.');
    }
  }
}
