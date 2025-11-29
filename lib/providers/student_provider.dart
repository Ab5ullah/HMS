import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../services/database_service.dart';

class StudentProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _hostelFilter;

  // Getters
  List<Student> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Fetch all students
  Future<void> fetchStudents({String? hostelId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getStudents(hostelId: hostelId, status: status);
      final studentsList = await stream.first; // Convert Stream to List
      _students = studentsList;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _students = [];
      _filteredStudents = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get student by ID
  Future<Student?> getStudent(String studentId) async {
    try {
      return await _dbService.getStudent(studentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Stream students (for real-time updates)
  Stream<List<Student>> streamStudents({String? hostelId, String? status}) {
    return _dbService.getStudents(hostelId: hostelId, status: status);
  }

  // Get student by UID
  Future<Student?> getStudentByUid(String uid) async {
    try {
      return await _dbService.getStudentByUid(uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add new student
  Future<bool> addStudent(Student student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createStudent(student);
      await fetchStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update student
  Future<bool> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateStudent(studentId, data);
      await fetchStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      await _dbService.deleteStudent(studentId);
      await fetchStudents();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search students
  void searchStudents(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // Filter by hostel
  void filterByHostel(String? hostelId) {
    _hostelFilter = hostelId;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _hostelFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (student.phoneNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      // Status filter
      final matchesStatus = _statusFilter == null || student.status == _statusFilter;

      // Hostel filter
      final matchesHostel = _hostelFilter == null || student.hostelId == _hostelFilter;

      return matchesSearch && matchesStatus && matchesHostel;
    }).toList();
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'total': _students.length,
      'active': _students.where((s) => s.status == 'active').length,
      'inactive': _students.where((s) => s.status == 'inactive').length,
      'archived': _students.where((s) => s.status == 'archived').length,
    };
  }
}
