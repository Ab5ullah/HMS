import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String studentId;
  final String uid;
  final String name;
  final String email;
  final String rollNo;
  final String? phoneNumber;
  final String? roomId;
  final String? profileImage;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final int? year;
  final int? semester;
  final DateTime? enrollmentDate;
  final String? guardianRelation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String hostelId;
  final String status;
  final DateTime admissionDate;
  final DateTime? graduationDate;
  final String? course;
  final String? department;
  final String? guardianName;
  final String? guardianPhone;
  final String? address;
  final String? photoUrl;
  final List<String> documents;

  Student({
    required this.studentId,
    required this.uid,
    required this.name,
    required this.email,
    required this.rollNo,
    this.phoneNumber,
    this.roomId,
    this.profileImage,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.year,
    this.semester,
    this.enrollmentDate,
    this.guardianRelation,
    required this.createdAt,
    required this.updatedAt,
    required this.hostelId,
    this.status = 'active',
    required this.admissionDate,
    this.graduationDate,
    this.course,
    this.department,
    this.guardianName,
    this.guardianPhone,
    this.address,
    this.photoUrl,
    this.documents = const [],
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      studentId: doc.id,
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      rollNo: data['rollNo'] ?? '',
      phoneNumber: data['phoneNumber'],
      roomId: data['roomId'],
      profileImage: data['profileImage'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'],
      bloodGroup: data['bloodGroup'],
      year: data['year'],
      semester: data['semester'],
      enrollmentDate: (data['enrollmentDate'] as Timestamp?)?.toDate(),
      guardianRelation: data['guardianRelation'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hostelId: data['hostelId'] ?? '',
      status: data['status'] ?? 'active',
      admissionDate: (data['admissionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      graduationDate: (data['graduationDate'] as Timestamp?)?.toDate(),
      course: data['course'],
      department: data['department'],
      guardianName: data['guardianName'],
      guardianPhone: data['guardianPhone'],
      address: data['address'],
      photoUrl: data['photoUrl'],
      documents: List<String>.from(data['documents'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'rollNo': rollNo,
      'phoneNumber': phoneNumber,
      'roomId': roomId,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'year': year,
      'semester': semester,
      'enrollmentDate': enrollmentDate != null ? Timestamp.fromDate(enrollmentDate!) : null,
      'guardianRelation': guardianRelation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hostelId': hostelId,
      'status': status,
      'admissionDate': Timestamp.fromDate(admissionDate),
      'graduationDate': graduationDate != null ? Timestamp.fromDate(graduationDate!) : null,
      'course': course,
      'department': department,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'address': address,
      'photoUrl': photoUrl,
      'documents': documents,
    };
  }

  Student copyWith({
    String? name,
    String? email,
    String? rollNo,
    String? phoneNumber,
    String? roomId,
    String? profileImage,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    int? year,
    int? semester,
    DateTime? enrollmentDate,
    String? guardianRelation,
    String? hostelId,
    String? status,
    DateTime? admissionDate,
    DateTime? graduationDate,
    String? course,
    String? department,
    String? guardianName,
    String? guardianPhone,
    String? address,
    String? photoUrl,
    List<String>? documents,
  }) {
    return Student(
      studentId: studentId,
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      rollNo: rollNo ?? this.rollNo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roomId: roomId ?? this.roomId,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      hostelId: hostelId ?? this.hostelId,
      status: status ?? this.status,
      admissionDate: admissionDate ?? this.admissionDate,
      graduationDate: graduationDate ?? this.graduationDate,
      course: course ?? this.course,
      department: department ?? this.department,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      documents: documents ?? this.documents,
    );
  }
}
