class WalletModel {
  final String walletId;
  final String currency;
  final double availableBalance;
  final String maskedAccountNumber;

  const WalletModel({
    required this.walletId,
    required this.currency,
    required this.availableBalance,
    required this.maskedAccountNumber,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] ?? 'WALLET10001',
      currency: json['currency'] ?? 'INR',
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      maskedAccountNumber: json['maskedAccountNumber'] ?? 'XXXX XXXX 4589',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'currency': currency,
      'availableBalance': availableBalance,
      'maskedAccountNumber': maskedAccountNumber,
    };
  }

  WalletModel copyWith({
    String? walletId,
    String? currency,
    double? availableBalance,
    String? maskedAccountNumber,
  }) {
    return WalletModel(
      walletId: walletId ?? this.walletId,
      currency: currency ?? this.currency,
      availableBalance: availableBalance ?? this.availableBalance,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
    );
  }
}
