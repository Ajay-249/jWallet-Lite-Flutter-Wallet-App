import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jwallet_lite/data/datasources/wallet_remote_data_source.dart';
import 'package:jwallet_lite/presentation/providers/wallet_state.dart';

void main() {
  double currentTestBalance = 24850.50;

  WalletRemoteDataSource createMockDataSource() {
    final mockClient = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/auth/login')) {
        final body = jsonDecode(request.body);
        if (body['email'] == 'demo@jstack.co' && body['password'] == 'Demo@123') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'accessToken': 'mock_test_token',
                'user': {
                  'id': 'USR10001',
                  'name': 'Ajay Dwivedi',
                  'email': 'demo@jstack.co',
                }
              }
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'success': false,
            'error': {'code': 'INVALID_CREDENTIALS', 'message': 'Invalid credentials'}
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/users/profile')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'USR10001',
              'name': 'Ajay Dwivedi',
              'email': 'demo@jstack.co',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/wallet/balance')) {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'walletId': 'WALLET10001',
              'currency': 'INR',
              'availableBalance': currentTestBalance,
              'maskedAccountNumber': 'XXXX XXXX 4589',
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/transactions/transfer')) {
        final body = jsonDecode(request.body);
        final amt = (body['amount'] as num).toDouble();
        if (amt > currentTestBalance) {
          return http.Response(
            jsonEncode({
              'success': false,
              'error': {
                'code': 'INSUFFICIENT_BALANCE',
                'message': 'Transfer amount exceeds available balance',
              }
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        }
        currentTestBalance -= amt;
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'transactionId': 'TXN-TEST-123456',
              'status': 'SUCCESS',
              'amount': amt,
              'currency': 'INR',
              'availableBalance': currentTestBalance,
            }
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.endsWith('/transactions')) {
        return http.Response(
          jsonEncode({'success': true, 'data': []}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('{"success": false}', 404);
    });

    return WalletRemoteDataSource(client: mockClient);
  }

  ProviderContainer createContainer() {
    final ds = createMockDataSource();
    return ProviderContainer(
      overrides: [
        walletProvider.overrideWith((ref) => WalletNotifier(remoteDataSource: ds)),
      ],
    );
  }

  group('1. Login Form Validation Tests', () {
    test('Invalid credentials set error message', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      final result = await notifier.login('wrong@email.com', 'WrongPass');

      expect(result, isFalse);
      expect(container.read(walletProvider).isAuthenticated, isFalse);
      expect(container.read(walletProvider).errorMessage, isNotNull);
    });

    test('Correct demo credentials authenticate successfully', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      final result = await notifier.login('demo@jstack.co', 'Demo@123');

      expect(result, isTrue);
      expect(container.read(walletProvider).isAuthenticated, isTrue);
      expect(container.read(walletProvider).user?.email, 'demo@jstack.co');
    });
  });

  group('2. Transfer Amount Validation Tests', () {
    test('Zero or negative transfer amount is rejected', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      final success = await notifier.processTransfer(
        beneficiaryName: 'Rahul Sharma',
        mobileNumber: '9876543210',
        amount: 0.00,
        idempotencyKey: 'TEST-IDEMP-001',
      );

      expect(success, isFalse);
    });
  });

  group('3. Insufficient Balance Handling Tests', () {
    test('Transfer exceeding current balance fails and sets error', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      final currentBalance =
          container.read(walletProvider).wallet?.availableBalance ?? 24850.50;

      final excessAmount = currentBalance + 50000.00;
      final success = await notifier.processTransfer(
        beneficiaryName: 'Rahul Sharma',
        mobileNumber: '9876543210',
        amount: excessAmount,
        idempotencyKey: 'TEST-IDEMP-002',
      );

      expect(success, isFalse);
      expect(container.read(walletProvider).errorMessage, isNotNull);
    });
  });

  group('4. Successful Transfer State Update Tests', () {
    test('Valid transfer deduces authoritative balance and prepends to history', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final notifier = container.read(walletProvider.notifier);
      final initialBalance =
          container.read(walletProvider).wallet?.availableBalance ?? 24850.50;
      final initialTxCount =
          container.read(walletProvider).transactions.length;

      const transferAmount = 1500.00;
      final success = await notifier.processTransfer(
        beneficiaryName: 'Rahul Sharma',
        mobileNumber: '9876543210',
        amount: transferAmount,
        idempotencyKey: 'TEST-IDEMP-003',
        remarks: 'Test Grocery Split',
      );

      expect(success, isTrue);

      final updatedState = container.read(walletProvider);
      final expectedBalance = initialBalance - transferAmount;

      // Authoritative balance deducted
      expect(updatedState.wallet?.availableBalance, closeTo(expectedBalance, 0.01));

      // Transaction added to top of history
      expect(updatedState.transactions.length, initialTxCount + 1);
      expect(updatedState.transactions.first.amount, transferAmount);
      expect(updatedState.transactions.first.beneficiaryName, 'Rahul Sharma');
      expect(updatedState.transactions.first.type, 'DEBIT');
    });
  });
}
