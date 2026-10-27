import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/wallet_model.dart';

class WalletState {
  final bool isSessionInitialized;
  final bool isAuthenticated;
  final bool isServerOnline;
  final bool isLoading;
  final String? errorMessage;
  final String? errorCode;
  final String? token;
  final UserModel? user;
  final WalletModel? wallet;
  final List<TransactionModel> transactions;
  final String transactionFilter; // 'ALL', 'DEBIT', 'CREDIT'
  final String searchQuery;

  const WalletState({
    this.isSessionInitialized = false,
    this.isAuthenticated = false,
    this.isServerOnline = true,
    this.isLoading = false,
    this.errorMessage,
    this.errorCode,
    this.token,
    this.user,
    this.wallet,
    this.transactions = const [],
    this.transactionFilter = 'ALL',
    this.searchQuery = '',
  });

  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      final matchesFilter =
          transactionFilter == 'ALL' ||
          (transactionFilter == 'DEBIT' && !tx.isCredit) ||
          (transactionFilter == 'CREDIT' && tx.isCredit);

      final matchesSearch =
          searchQuery.isEmpty ||
          tx.beneficiaryName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          tx.id.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();
  }

  WalletState copyWith({
    bool? isSessionInitialized,
    bool? isAuthenticated,
    bool? isServerOnline,
    bool? isLoading,
    String? errorMessage,
    String? errorCode,
    String? token,
    UserModel? user,
    WalletModel? wallet,
    List<TransactionModel>? transactions,
    String? transactionFilter,
    String? searchQuery,
  }) {
    return WalletState(
      isSessionInitialized: isSessionInitialized ?? this.isSessionInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isServerOnline: isServerOnline ?? this.isServerOnline,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      errorCode: errorCode,
      token: token ?? this.token,
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      transactionFilter: transactionFilter ?? this.transactionFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRemoteDataSource _remoteDataSource;
  AuthLocalDataSource? _localDataSource;

  WalletNotifier({
    WalletRemoteDataSource? remoteDataSource,
    this._localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? WalletRemoteDataSource(),
       super(
         WalletState(
           user: const UserModel(
             id: 'USR10001',
             name: 'Ajay Dwivedi',
             email: 'demo@jstack.co',
           ),
           wallet: const WalletModel(
             walletId: 'WALLET10001',
             currency: 'INR',
             availableBalance: 24850.50,
             maskedAccountNumber: 'XXXX XXXX 4589',
           ),
           transactions: _initialSampleTransactions,
         ),
       ) {
    _initLocalAuth();
  }

  Future<void> _initLocalAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _localDataSource = AuthLocalDataSource(prefs);

      if (_localDataSource!.hasValidSession()) {
        final token = _localDataSource!.getToken();
        final cachedUser = _localDataSource!.getCachedUser();
        state = state.copyWith(
          isSessionInitialized: true,
          isAuthenticated: true,
          token: token,
          user: cachedUser ?? state.user,
        );
        refreshData();
      } else {
        state = state.copyWith(isSessionInitialized: true);
      }
    } catch (_) {
      state = state.copyWith(isSessionInitialized: true);
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(transactionFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final token = result['token'] as String;
      final user = result['user'] as UserModel;

      if (_localDataSource != null) {
        await _localDataSource!.saveAuthSession(token: token, user: user);
      }

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
        user: user,
      );

      // Fetch authoritative balance and transactions from server
      await refreshData();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      // Fallback for demo when backend is offline
      if (email.trim().toLowerCase() == 'demo@jstack.co' &&
          password == 'Demo@123') {
        const token = 'mock_access_token_123';
        const user = UserModel(
          id: 'USR10001',
          name: 'Ajay Dwivedi',
          email: 'demo@jstack.co',
        );
        if (_localDataSource != null) {
          await _localDataSource!.saveAuthSession(token: token, user: user);
        }
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          user: user,
        );
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid credentials. Use demo@jstack.co / Demo@123',
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (_localDataSource != null) {
      await _localDataSource!.clearSession();
    }
    state = state.copyWith(isAuthenticated: false, token: null);
  }

  Future<void> refreshData() async {
    final token = state.token ?? 'mock_access_token_123';
    state = state.copyWith(isLoading: true);

    try {
      final balanceFuture = _remoteDataSource.getWalletBalance(token);
      final txFuture = _remoteDataSource.getTransactions(token);
      final profileFuture = _remoteDataSource.getUserProfile(token);

      final results = await Future.wait([
        balanceFuture,
        txFuture,
        profileFuture,
      ]);
      final wallet = results[0] as WalletModel;
      final txs = results[1] as List<TransactionModel>;
      final user = results[2] as UserModel;

      if (_localDataSource != null) {
        await _localDataSource!.saveAuthSession(token: token, user: user);
      }

      state = state.copyWith(
        isLoading: false,
        isServerOnline: true,
        wallet: wallet,
        transactions: txs,
        user: user,
      );
    } catch (_) {
      // Offline fallback: simulate delay
      await Future.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(isLoading: false, isServerOnline: false);
    }
  }

  Future<bool> processTransfer({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    required String idempotencyKey,
    String? remarks,
  }) async {
    final token = state.token ?? 'mock_access_token_123';
    // final currentBalance = state.wallet?.availableBalance ?? 0.0;

    // Client pre-check only for amount <= 0
    if (amount <= 0) {
      state = state.copyWith(
        errorMessage: 'Transfer amount must be greater than zero',
        errorCode: 'INVALID_AMOUNT',
      );
      return false;
    }

    try {
      final result = await _remoteDataSource.transferMoney(
        token: token,
        idempotencyKey: idempotencyKey,
        beneficiaryName: beneficiaryName,
        mobileNumber: mobileNumber,
        amount: amount,
        remarks: remarks,
      );

      final newBalance = (result['availableBalance'] as num).toDouble();
      final txId = result['transactionId'] as String;

      final newTx = TransactionModel(
        id: txId,
        type: 'DEBIT',
        amount: amount,
        currency: 'INR',
        beneficiaryName: beneficiaryName,
        status: 'SUCCESS',
        createdAt: DateTime.now(),
        remarks: remarks ?? 'Instant P2P Transfer',
        mobileNumber: mobileNumber,
        category: 'P2P',
      );

      state = state.copyWith(
        wallet: state.wallet?.copyWith(availableBalance: newBalance),
        transactions: [newTx, ...state.transactions],
        errorMessage: null,
        errorCode: null,
      );
      return true;
    } on ApiException catch (e) {
      String reason;
      if (e.code == 'INSUFFICIENT_BALANCE') {
        reason = 'Insufficient Funds';
      } else if (e.code == 'NETWORK_ERROR' ||
          e.code == 'CONNECTION_ERROR' ||
          e.message == 'Server Unavailable') {
        reason = 'Server Unavailable';
      } else if (e.code == 'TIMEOUT_ERROR') {
        reason = 'Request Timeout';
      } else if (e.statusCode == 500 || e.code == 'SERVER_ERROR') {
        reason = 'Backend Server Error';
      } else {
        reason = e.message.isNotEmpty ? e.message : 'Transfer Failed';
      }

      final failedTx = TransactionModel(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}',
        type: 'DEBIT',
        amount: amount,
        currency: 'INR',
        beneficiaryName: beneficiaryName,
        status: 'FAILED',
        createdAt: DateTime.now(),
        remarks: reason,
        mobileNumber: mobileNumber,
        category: 'P2P',
      );

      state = state.copyWith(
        transactions: [failedTx, ...state.transactions],
        errorMessage: e.message,
        errorCode: e.code,
      );
      return false;
    } catch (_) {
      const reason = 'Server Unavailable';
      final failedTx = TransactionModel(
        id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}',
        type: 'DEBIT',
        amount: amount,
        currency: 'INR',
        beneficiaryName: beneficiaryName,
        status: 'FAILED',
        createdAt: DateTime.now(),
        remarks: reason,
        mobileNumber: mobileNumber,
        category: 'P2P',
      );

      state = state.copyWith(
        isServerOnline: false,
        transactions: [failedTx, ...state.transactions],
        errorMessage: 'Server Unavailable',
        errorCode: 'ERR_SERVER_UNREACHABLE',
      );
      return false;
    }
  }

  static final List<TransactionModel> _initialSampleTransactions = [
    TransactionModel(
      id: 'TXN-984210488219',
      type: 'DEBIT',
      amount: 1500.00,
      currency: 'INR',
      beneficiaryName: 'Rahul Sharma',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      remarks: 'Dinner & groceries split',
      mobileNumber: '+91 98765 43210',
      category: 'P2P',
    ),
    TransactionModel(
      id: 'TXN-984205118902',
      type: 'DEBIT',
      amount: 340.00,
      currency: 'INR',
      beneficiaryName: 'Blue Tokai Coffee',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      remarks: 'POS Terminal 12',
      category: 'MERCHANT',
    ),
    TransactionModel(
      id: 'TXN-984180491823',
      type: 'CREDIT',
      amount: 45000.00,
      currency: 'INR',
      beneficiaryName: 'Salary Deposit (JStack)',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      remarks: 'JStack Technologies Monthly Payroll',
      category: 'NEFT',
    ),
    TransactionModel(
      id: 'TXN-984166291040',
      type: 'DEBIT',
      amount: 480.00,
      currency: 'INR',
      beneficiaryName: 'Swiggy Instant',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      remarks: 'Order #SWG-8912',
      category: 'DINING',
    ),
    TransactionModel(
      id: 'TXN-984155104822',
      type: 'CREDIT',
      amount: 240.00,
      currency: 'INR',
      beneficiaryName: 'Uber India Refund',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      remarks: 'Ride fare adjustment refund',
      category: 'REFUND',
    ),
    TransactionModel(
      id: 'TXN-984099281033',
      type: 'CREDIT',
      amount: 150.00,
      currency: 'INR',
      beneficiaryName: 'Cashback Reward',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      remarks: 'jWallet Auto-Perks Cash bonus',
      category: 'BONUS',
    ),
    TransactionModel(
      id: 'TXN-984012984920',
      type: 'DEBIT',
      amount: 2100.00,
      currency: 'INR',
      beneficiaryName: 'Priya Nair',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      remarks: 'Weekend road trip expenses',
      mobileNumber: '+91 98112 33445',
      category: 'P2P',
    ),
    TransactionModel(
      id: 'TXN-983988410284',
      type: 'DEBIT',
      amount: 620.00,
      currency: 'INR',
      beneficiaryName: 'Zomato Online',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      remarks: 'Order #ZM-8419',
      category: 'DINING',
    ),
    TransactionModel(
      id: 'TXN-983902910488',
      type: 'DEBIT',
      amount: 1380.00,
      currency: 'INR',
      beneficiaryName: 'Electricity Bill (BESCOM)',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      remarks: 'Consumer #5589124',
      category: 'UTILITY',
    ),
    TransactionModel(
      id: 'TXN-983811902834',
      type: 'CREDIT',
      amount: 5000.00,
      currency: 'INR',
      beneficiaryName: 'Amit Kumar',
      status: 'SUCCESS',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      remarks: 'Freelance project milestone',
      mobileNumber: '+91 97654 32109',
      category: 'P2P',
    ),
  ];
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});
