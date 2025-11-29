import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? hostelId;
  final String status;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.hostelId,
    this.status = 'active',
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'student'),
      hostelId: data['hostelId'],
      status: data['status'] ?? 'active',
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'hostelId': hostelId,
      'status': status,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  AppUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? hostelId,
    String? status,
    String? phoneNumber,
    String? photoUrl,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      hostelId: hostelId ?? this.hostelId,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
