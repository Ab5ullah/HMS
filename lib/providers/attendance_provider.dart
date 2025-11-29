import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/database_service.dart';

class AttendanceProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Attendance> _attendanceList = [];
  List<Attendance> _filteredAttendance = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _dateFilter;
  String? _statusFilter;

  // Getters
  List<Attendance> get attendance => _filteredAttendance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch attendance records
  Future<void> fetchAttendance({
    String? studentId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getAttendance(
        studentId: studentId,
        date: date,
        startDate: startDate,
        endDate: endDate,
      );
      final records = await stream.first;
      _attendanceList = records;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _attendanceList = [];
      _filteredAttendance = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark attendance
  Future<bool> markAttendance(Attendance attendance) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createAttendance(attendance);
      await fetchAttendance();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update attendance
  Future<bool> updateAttendance(String attendanceId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateAttendance(attendanceId, data);
      await fetchAttendance();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get attendance for specific student and date
  Future<Attendance?> getStudentAttendanceForDate(String studentId, DateTime date) async {
    try {
      final stream = _dbService.getAttendance(
        studentId: studentId,
        date: date,
      );
      final records = await stream.first;
      return records.isNotEmpty ? records.first : null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Check if attendance already marked for today
  Future<bool> isAttendanceMarkedToday(String studentId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final record = await getStudentAttendanceForDate(studentId, todayDate);
    return record != null;
  }

  // Filter by date
  void filterByDate(DateTime? date) {
    _dateFilter = date;
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _dateFilter = null;
    _statusFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredAttendance = _attendanceList.where((record) {
      // Date filter
      final matchesDate = _dateFilter == null ||
          (record.date.year == _dateFilter!.year &&
           record.date.month == _dateFilter!.month &&
           record.date.day == _dateFilter!.day);

      // Status filter
      final matchesStatus = _statusFilter == null || record.status == _statusFilter;

      return matchesDate && matchesStatus;
    }).toList();
  }

  // Get attendance statistics for a student
  Map<String, dynamic> getStudentStatistics(String studentId) {
    final studentRecords = _attendanceList.where((r) => r.studentId == studentId).toList();
    final present = studentRecords.where((r) => r.status == 'present').length;
    final absent = studentRecords.where((r) => r.status == 'absent').length;
    final total = studentRecords.length;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0';

    return {
      'total': total,
      'present': present,
      'absent': absent,
      'percentage': percentage,
    };
  }

  // Get overall statistics
  Map<String, dynamic> getStatistics() {
    final presentToday = _attendanceList.where((r) => 
      r.status == 'present' && _isToday(r.date)
    ).length;
    
    final absentToday = _attendanceList.where((r) => 
      r.status == 'absent' && _isToday(r.date)
    ).length;

    return {
      'total': _attendanceList.length,
      'presentToday': presentToday,
      'absentToday': absentToday,
      'present': _attendanceList.where((r) => r.status == 'present').length,
      'absent': _attendanceList.where((r) => r.status == 'absent').length,
    };
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Get absent students for today
  List<String> getTodayAbsentStudents() {
    final today = DateTime.now();
    return _attendanceList
        .where((r) => 
          r.status == 'absent' &&
          r.date.year == today.year &&
          r.date.month == today.month &&
          r.date.day == today.day)
        .map((r) => r.studentId)
        .toList();
  }
}
