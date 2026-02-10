class DonationTransactionModel {
  final int id;
  final String transactionId;
  final int amount;
  final int donorId;
  final String recipientType; // 'church' ou 'pastor'
  final int recipientId;
  final String? message;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  
  // Info du bénéficiaire (pour affichage)
  final String? recipientName;
  final String? recipientPhoto;

  DonationTransactionModel({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.donorId,
    required this.recipientType,
    required this.recipientId,
    this.message,
    required this.status,
    required this.createdAt,
    this.recipientName,
    this.recipientPhoto,
  });

  factory DonationTransactionModel.fromJson(Map<String, dynamic> json) {
    return DonationTransactionModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      amount: json['amount'],
      donorId: json['donor_id'],
      recipientType: json['recipient_type'],
      recipientId: json['recipient_id'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      recipientName: json['recipient_name'],
      recipientPhoto: json['recipient_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'amount': amount,
      'donor_id': donorId,
      'recipient_type': recipientType,
      'recipient_id': recipientId,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'recipient_name': recipientName,
      'recipient_photo': recipientPhoto,
    };
  }
}
