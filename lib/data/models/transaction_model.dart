class TransactionModel {
  final String id;
  final String type; // 'CREDIT' or 'DEBIT'
  final double amount;
  final String currency;
  final String beneficiaryName;
  final String status; // 'SUCCESS', 'FAILED', 'PENDING'
  final DateTime createdAt;
  final String? remarks;
  final String? mobileNumber;
  final String? category; // 'P2P', 'NEFT', 'MERCHANT', 'BONUS', 'DINING'

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.beneficiaryName,
    required this.status,
    required this.createdAt,
    this.remarks,
    this.mobileNumber,
    this.category,
  });

  bool get isCredit => type.toUpperCase() == 'CREDIT';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['createdAt']);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: json['id'] ?? '',
      type: (json['type'] ?? 'DEBIT').toString().toUpperCase(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      beneficiaryName: json['beneficiaryName'] ?? 'Unknown',
      status: (json['status'] ?? 'SUCCESS').toString().toUpperCase(),
      createdAt: parsedDate,
      remarks: json['remarks'],
      mobileNumber: json['mobileNumber'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'beneficiaryName': beneficiaryName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'remarks': remarks,
      'mobileNumber': mobileNumber,
      'category': category,
    };
  }
}
