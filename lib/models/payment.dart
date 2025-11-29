import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String paymentId;
  final String studentId;
  final double amount;
  final String paymentType;
  final DateTime dueDate;
  final String status;
  final double paidAmount;
  final double dueAmount;
  final DateTime? paidDate;
  final String? transactionId;
  final DateTime createdAt;
  final String? remarks;

  // Aliases for compatibility
  double get totalAmount => amount;
  String get type => paymentType;
  DateTime? get paidAt => paidDate;

  Payment({
    required this.paymentId,
    required this.studentId,
    required this.amount,
    required this.paymentType,
    required this.dueDate,
    this.status = 'pending',
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.paidDate,
    this.transactionId,
    required this.createdAt,
    this.remarks,
  });

  double get remainingAmount => amount - paidAmount;
  bool get isFullyPaid => paidAmount >= amount;

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Payment(
      paymentId: doc.id,
      studentId: data['studentId'] ?? '',
      amount: (data['amount'] ?? data['totalAmount'] ?? 0).toDouble(),
      paymentType: data['paymentType'] ?? data['type'] ?? 'Hostel Fee',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      dueAmount: (data['dueAmount'] ?? 0).toDouble(),
      paidDate: (data['paidDate'] as Timestamp?)?.toDate(),
      transactionId: data['transactionId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      remarks: data['remarks'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'amount': amount,
      'paymentType': paymentType,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'remarks': remarks,
    };
  }
}
