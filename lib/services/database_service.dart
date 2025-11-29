import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/room.dart';
import '../models/attendance.dart';
import '../models/mess.dart';
import '../models/payment.dart';
import '../models/leave.dart';
import '../models/complaint.dart';
import '../models/hostel.dart';
import '../models/app_user.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? AppUser.fromFirestore(doc) : null;
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<AppUser>> getPendingUsers() {
    return _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList(),
        );
  }

  Future<void> approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'active',
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> rejectUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'rejected',
      'updatedAt': Timestamp.now(),
    });
  }

  // Student operations
  Future<String> createStudent(Student student) async {
    final doc = await _firestore.collection('students').add(student.toFirestore());
    return doc.id;
  }

  Future<Student?> getStudent(String studentId) async {
    final doc = await _firestore.collection('students').doc(studentId).get();
    return doc.exists ? Student.fromFirestore(doc) : null;
  }

  Future<Student?> getStudentByUid(String uid) async {
    final query = await _firestore
        .collection('students')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? Student.fromFirestore(query.docs.first) : null;
  }

  Stream<List<Student>> getStudents({String? hostelId, String? status}) {
    Query query = _firestore.collection('students');

    if (hostelId != null) {
      query = query.where('hostelId', isEqualTo: hostelId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    await _firestore.collection('students').doc(studentId).update(data);
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).delete();
  }

  // Room operations
  Future<String> createRoom(Room room) async {
    final doc = await _firestore.collection('rooms').add(room.toFirestore());
    return doc.id;
  }

  Future<Room?> getRoom(String roomId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    return doc.exists ? Room.fromFirestore(doc) : null;
  }

  Stream<List<Room>> getRooms({String? hostelId, String? status}) {
    Query query = _firestore.collection('rooms');

    if (hostelId != null) {
      query = query.where('hostelId', isEqualTo: hostelId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _firestore.collection('rooms').doc(roomId).update(data);
  }

  Future<void> allocateRoom(String roomId, String studentId) async {
    final room = await getRoom(roomId);
    if (room == null) throw Exception('Room not found');

    if (room.occupants.length >= room.capacity) {
      throw Exception('Room is full');
    }

    await _firestore.collection('rooms').doc(roomId).update({
      'occupants': FieldValue.arrayUnion([studentId]),
    });

    await _firestore.collection('students').doc(studentId).update({
      'roomId': roomId,
    });
  }

  Future<void> deallocateRoom(String roomId, String studentId) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'occupants': FieldValue.arrayRemove([studentId]),
    });

    await _firestore.collection('students').doc(studentId).update({
      'roomId': null,
    });
  }

  // Attendance operations
  Future<String> createAttendance(Attendance attendance) async {
    final doc = await _firestore.collection('attendance').add(attendance.toFirestore());
    return doc.id;
  }

  Stream<List<Attendance>> getAttendance({
    String? studentId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('attendance');

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay));
    }

    if (startDate != null && endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateAttendance(String attendanceId, Map<String, dynamic> data) async {
    await _firestore.collection('attendance').doc(attendanceId).update(data);
  }

  // Visitor log operations
  Future<String> createVisitorLog(VisitorLog log) async {
    final doc = await _firestore.collection('visitor_logs').add(log.toFirestore());
    return doc.id;
  }

  Stream<List<VisitorLog>> getVisitorLogs({
    String? studentId,
    DateTime? date,
  }) {
    Query query = _firestore.collection('visitor_logs').orderBy('date', descending: true);

    if (studentId != null) {
      query = query.where('studentVisited', isEqualTo: studentId);
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay));
    }

    return query.limit(100).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => VisitorLog.fromFirestore(doc)).toList(),
        );
  }

  // Mess menu operations
  Future<String> createMessMenu(MessMenu menu) async {
    final doc = await _firestore.collection('mess_menu').add(menu.toFirestore());
    return doc.id;
  }

  Future<MessMenu?> getMessMenuByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection('mess_menu')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? MessMenu.fromFirestore(query.docs.first) : null;
  }

  Stream<List<MessMenu>> getMessMenus({DateTime? startDate, DateTime? endDate}) {
    Query query = _firestore.collection('mess_menu').orderBy('date', descending: true);

    if (startDate != null && endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.limit(30).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => MessMenu.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateMessMenu(String menuId, Map<String, dynamic> data) async {
    await _firestore.collection('mess_menu').doc(menuId).update(data);
  }

  // Mess attendance operations
  Future<String> createMessAttendance(MessAttendance attendance) async {
    final doc = await _firestore.collection('mess_attendance').add(attendance.toFirestore());
    return doc.id;
  }

  Stream<List<MessAttendance>> getMessAttendance({
    String? studentId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore.collection('mess_attendance');

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay));
    }

    if (startDate != null && endDate != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => MessAttendance.fromFirestore(doc)).toList(),
        );
  }

  // Mess inventory operations
  Future<String> createMessInventory(MessInventory inventory) async {
    final doc = await _firestore.collection('mess_inventory').add(inventory.toFirestore());
    return doc.id;
  }

  Stream<List<MessInventory>> getMessInventory() {
    return _firestore
        .collection('mess_inventory')
        .orderBy('itemName')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MessInventory.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateMessInventory(String inventoryId, Map<String, dynamic> data) async {
    await _firestore.collection('mess_inventory').doc(inventoryId).update(data);
  }

  // Payment operations
  Future<String> createPayment(Payment payment) async {
    final doc = await _firestore.collection('payments').add(payment.toFirestore());
    return doc.id;
  }

  Future<Payment?> getPayment(String paymentId) async {
    final doc = await _firestore.collection('payments').doc(paymentId).get();
    return doc.exists ? Payment.fromFirestore(doc) : null;
  }

  Stream<List<Payment>> getPayments({
    String? studentId,
    String? status,
    int? year,
  }) {
    Query query = _firestore.collection('payments').orderBy('dueDate', descending: true);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (year != null) {
      query = query.where('year', isEqualTo: year);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updatePayment(String paymentId, Map<String, dynamic> data) async {
    await _firestore.collection('payments').doc(paymentId).update(data);
  }

  // Leave operations
  Future<String> createLeave(Leave leave) async {
    final doc = await _firestore.collection('leaves').add(leave.toFirestore());
    return doc.id;
  }

  Stream<List<Leave>> getLeaves({
    String? studentId,
    String? status,
  }) {
    Query query = _firestore.collection('leaves').orderBy('createdAt', descending: true);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Leave.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateLeave(String leaveId, Map<String, dynamic> data) async {
    await _firestore.collection('leaves').doc(leaveId).update(data);
  }

  // Complaint operations
  Future<String> createComplaint(Complaint complaint) async {
    final doc = await _firestore.collection('complaints').add(complaint.toFirestore());
    return doc.id;
  }

  Stream<List<Complaint>> getComplaints({
    String? studentId,
    String? status,
    String? category,
  }) {
    Query query = _firestore.collection('complaints').orderBy('createdAt', descending: true);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Complaint.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateComplaint(String complaintId, Map<String, dynamic> data) async {
    await _firestore.collection('complaints').doc(complaintId).update(data);
  }

  // Hostel operations
  Future<String> createHostel(Hostel hostel) async {
    final doc = await _firestore.collection('hostels').add(hostel.toFirestore());
    return doc.id;
  }

  Future<Hostel?> getHostel(String hostelId) async {
    final doc = await _firestore.collection('hostels').doc(hostelId).get();
    return doc.exists ? Hostel.fromFirestore(doc) : null;
  }

  Stream<List<Hostel>> getHostels() {
    return _firestore.collection('hostels').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Hostel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateHostel(String hostelId, Map<String, dynamic> data) async {
    await _firestore.collection('hostels').doc(hostelId).update(data);
  }
}
