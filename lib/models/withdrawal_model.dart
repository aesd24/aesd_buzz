class WithdrawalModel {
  final int id;
  final String walletType; // 'church' ou 'pastor'
  final int walletId;
  final int userId;
  final int amount;
  final String phoneNumber;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final String? adminNotes;
  final DateTime requestedAt;
  final DateTime? processedAt;

  WithdrawalModel({
    required this.id,
    required this.walletType,
    required this.walletId,
    required this.userId,
    required this.amount,
    required this.phoneNumber,
    required this.status,
    this.adminNotes,
    required this.requestedAt,
    this.processedAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: json['id'],
      walletType: json['wallet_type'],
      walletId: json['wallet_id'],
      userId: json['user_id'],
      amount: json['amount'],
      phoneNumber: json['phone_number'],
      status: json['status'],
      adminNotes: json['admin_notes'],
      requestedAt: DateTime.parse(json['requested_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_type': walletType,
      'wallet_id': walletId,
      'user_id': userId,
      'amount': amount,
      'phone_number': phoneNumber,
      'status': status,
      'admin_notes': adminNotes,
      'requested_at': requestedAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      case 'completed':
        return 'Complété';
      default:
        return status;
    }
  }
}
