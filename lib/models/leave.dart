import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  static LeaveStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }
}

class Leave {
  final String leaveId;
  final String studentId;
  final String leaveType;  // Added field
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;
  final String status;  // Using String for compatibility
  final String? approvedBy;
  final DateTime? approvedAt;  // Fixed field name
  final String? rejectedBy;    // Added field
  final DateTime? rejectedAt;  // Added field
  final String? rejectionReason;
  final DateTime createdAt;

  Leave({
    required this.leaveId,
    required this.studentId,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.reason,
    this.status = 'pending',
    this.approvedBy,
    this.approvedAt,
    this.rejectedBy,
    this.rejectedAt,
    this.rejectionReason,
    required this.createdAt,
  });

  int get durationInDays => toDate.difference(fromDate).inDays + 1;

  factory Leave.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Leave(
      leaveId: doc.id,
      studentId: data['studentId'] ?? '',
      leaveType: data['leaveType'] ?? 'home',
      fromDate: (data['fromDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      toDate: (data['toDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      approvedBy: data['approvedBy'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      rejectedBy: data['rejectedBy'],
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'leaveType': leaveType,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'reason': reason,
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectedBy': rejectedBy,
      'rejectedAt': rejectedAt != null ? Timestamp.fromDate(rejectedAt!) : null,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
