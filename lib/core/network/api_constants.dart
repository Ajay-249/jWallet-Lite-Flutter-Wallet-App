import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Automatically resolves for Android Emulator (10.0.2.2) vs Desktop/iOS/Web (localhost)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is the special alias to your host loopback interface on Android emulator
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String userProfile = '/users/profile';
  static const String walletBalance = '/wallet/balance';
  static const String transactions = '/transactions';
  static const String transfer = '/transactions/transfer';

  static String transactionDetails(String id) => '/transactions/$id';
}
