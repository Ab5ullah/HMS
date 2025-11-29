import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String attendanceId;
  final String studentId;
  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? remarks;

  Attendance({
    required this.attendanceId,
    required this.studentId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.status = 'present',
    this.latitude,
    this.longitude,
    this.remarks,
  });

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Attendance(
      attendanceId: doc.id,
      studentId: data['studentId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkInTime: data['checkInTime'],
      checkOutTime: data['checkOutTime'],
      status: data['status'] ?? 'present',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      remarks: data['remarks'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'remarks': remarks,
    };
  }
}

class VisitorLog {
  final String logId;
  final String visitorName;
  final String studentVisited;
  final String? location;
  final DateTime? markedAt;
  final DateTime createdAt;
  final String inTime;
  final String? outTime;
  final String? visitorPhone;
  final String? visitorId;

  VisitorLog({
    required this.logId,
    required this.visitorName,
    required this.studentVisited,
    this.location,
    this.markedAt,
    required this.createdAt,
    required this.inTime,
    this.outTime,
    this.visitorPhone,
    this.visitorId,
  });

  factory VisitorLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitorLog(
      logId: doc.id,
      visitorName: data['visitorName'] ?? '',
      studentVisited: data['studentVisited'] ?? '',
      location: data['location'],
      markedAt: (data['markedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      inTime: data['inTime'] ?? '',
      outTime: data['outTime'],
      visitorPhone: data['visitorPhone'],
      visitorId: data['visitorId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'visitorName': visitorName,
      'studentVisited': studentVisited,
      'location': location,
      'markedAt': markedAt != null ? Timestamp.fromDate(markedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'inTime': inTime,
      'outTime': outTime,
      'visitorPhone': visitorPhone,
      'visitorId': visitorId,
    };
  }
}
