import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }

  static ComplaintStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'inprogress':
      case 'in_progress':
        return ComplaintStatus.inProgress;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'closed':
        return ComplaintStatus.closed;
      default:
        return ComplaintStatus.pending;
    }
  }
}

enum ComplaintCategory {
  room,
  mess,
  maintenance,
  other;

  String get displayName {
    switch (this) {
      case ComplaintCategory.room:
        return 'Room';
      case ComplaintCategory.mess:
        return 'Mess';
      case ComplaintCategory.maintenance:
        return 'Maintenance';
      case ComplaintCategory.other:
        return 'Other';
    }
  }

  static ComplaintCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'room':
        return ComplaintCategory.room;
      case 'mess':
        return ComplaintCategory.mess;
      case 'maintenance':
        return ComplaintCategory.maintenance;
      case 'other':
        return ComplaintCategory.other;
      default:
        return ComplaintCategory.other;
    }
  }
}

enum ComplaintPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ComplaintPriority.low:
        return 'Low';
      case ComplaintPriority.medium:
        return 'Medium';
      case ComplaintPriority.high:
        return 'High';
      case ComplaintPriority.urgent:
        return 'Urgent';
    }
  }

  static ComplaintPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return ComplaintPriority.low;
      case 'medium':
        return ComplaintPriority.medium;
      case 'high':
        return ComplaintPriority.high;
      case 'urgent':
        return ComplaintPriority.urgent;
      default:
        return ComplaintPriority.medium;
    }
  }
}

class Complaint {
  final String complaintId;
  final String studentId;
  final String title;
  final String description;
  final String category;  // Using String for compatibility
  final String priority;  // Using String for compatibility
  final String status;    // Using String for compatibility
  final String? assignedTo;
  final String? response;  // Changed from resolution
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String> images;

  Complaint({
    required this.complaintId,
    required this.studentId,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 'medium',
    this.status = 'pending',
    this.assignedTo,
    this.response,
    required this.createdAt,
    this.resolvedAt,
    this.images = const [],
  });

  factory Complaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      complaintId: doc.id,
      studentId: data['studentId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'other',
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'pending',
      assignedTo: data['assignedTo'],
      response: data['response'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      images: List<String>.from(data['images'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'response': response,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'images': images,
    };
  }
}
