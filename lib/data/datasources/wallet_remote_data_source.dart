import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_constants.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

class WalletRemoteDataSource {
  final http.Client client;

  WalletRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  Map<String, String> _headers([String? token, String? idempotencyKey]) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      map['Authorization'] = 'Bearer $token';
    }
    if (idempotencyKey != null) {
      map['Idempotency-Key'] = idempotencyKey;
    }
    return map;
  }

  Future<http.Response> _executeWithTimeout(
    Future<http.Response> Function() requestFn,
  ) async {
    try {
      return await requestFn().timeout(const Duration(seconds: 6));
    } on TimeoutException {
      throw ApiException(
        statusCode: 408,
        code: 'TIMEOUT_ERROR',
        message: 'Connection timed out. Server took too long to respond.',
      );
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        code: 'NETWORK_ERROR',
        message: 'Server Unavailable',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 0,
        code: 'CONNECTION_ERROR',
        message: 'Server Unavailable',
      );
    }
  }

  Never _handleError(http.Response response) {
    String code = 'API_ERROR';
    String message = 'An unexpected server error occurred';

    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] is Map) {
        code = body['error']['code'] ?? code;
        message = body['error']['message'] ?? message;
      }
    } catch (_) {
      message = 'Failed with status code: ${response.statusCode}';
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
  }

  // API 1: Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final response = await _executeWithTimeout(() => client.post(
          url,
          headers: _headers(),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      final accessToken = data['accessToken'] as String;
      debugPrint('📡 [HTTP 200 /auth/login] Token: $accessToken');
      return {
        'token': accessToken,
        'user': UserModel.fromJson(data['user']),
      };
    }

    _handleError(response);
  }

  // API 2: User Profile
  Future<UserModel> getUserProfile(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userProfile}');
    final response =
        await _executeWithTimeout(() => client.get(url, headers: _headers(token)));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return UserModel.fromJson(body['data']);
    }

    _handleError(response);
  }

  // API 3: Wallet Balance
  Future<WalletModel> getWalletBalance(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletBalance}');
    final response =
        await _executeWithTimeout(() => client.get(url, headers: _headers(token)));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return WalletModel.fromJson(body['data']);
    }

    _handleError(response);
  }

  // API 4: Transaction History
  Future<List<TransactionModel>> getTransactions(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactions}');
    final response =
        await _executeWithTimeout(() => client.get(url, headers: _headers(token)));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List list = body['data'] ?? [];
      return list.map((item) => TransactionModel.fromJson(item)).toList();
    }

    _handleError(response);
  }

  // API 5: Money Transfer
  Future<Map<String, dynamic>> transferMoney({
    required String token,
    required String idempotencyKey,
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transfer}');
    final response = await _executeWithTimeout(() => client.post(
          url,
          headers: _headers(token, idempotencyKey),
          body: jsonEncode({
            'beneficiaryName': beneficiaryName,
            'mobileNumber': mobileNumber,
            'amount': amount,
            'remarks': remarks,
          }),
        ));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] as Map<String, dynamic>;
    }

    _handleError(response);
  }

  // API 6: Transaction Details
  Future<TransactionModel> getTransactionDetails({
    required String token,
    required String id,
  }) async {
    final url =
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.transactionDetails(id)}');
    final response =
        await _executeWithTimeout(() => client.get(url, headers: _headers(token)));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return TransactionModel.fromJson(body['data']);
    }

    _handleError(response);
  }
}
