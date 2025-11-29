import 'package:flutter/foundation.dart';
import '../models/leave.dart';
import '../services/database_service.dart';

class LeaveProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Leave> _leaves = [];
  List<Leave> _filteredLeaves = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _typeFilter;

  // Getters
  List<Leave> get leaves => _filteredLeaves;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all leaves
  Future<void> fetchLeaves({
    String? studentId,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getLeaves(
        studentId: studentId,
        status: status,
      );
      final leavesList = await stream.first;
      _leaves = leavesList;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _leaves = [];
      _filteredLeaves = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get leave by ID
  Future<Leave?> getLeave(String leaveId) async {
    try {
      // Find in cached list first
      final leave = _leaves.where((l) => l.leaveId == leaveId).firstOrNull;
      return leave;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get leaves for a student
  Future<List<Leave>> getStudentLeaves(String studentId) async {
    try {
      final stream = _dbService.getLeaves(studentId: studentId);
      return await stream.first;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Submit new leave application
  Future<bool> submitLeave(Leave leave) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createLeave(leave);
      await fetchLeaves();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update leave
  Future<bool> updateLeave(String leaveId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateLeave(leaveId, data);
      await fetchLeaves();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Approve leave
  Future<bool> approveLeave(String leaveId, String approvedBy) async {
    try {
      await updateLeave(leaveId, {
        'status': 'approved',
        'approvedBy': approvedBy,
        'approvedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reject leave
  Future<bool> rejectLeave(String leaveId, String rejectedBy, String? reason) async {
    try {
      await updateLeave(leaveId, {
        'status': 'rejected',
        'rejectedBy': rejectedBy,
        'rejectedAt': DateTime.now(),
        'rejectionReason': reason,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search leaves
  void searchLeaves(String query) {
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

  // Filter by type
  void filterByType(String? type) {
    _typeFilter = type;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _typeFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    _filteredLeaves = _leaves.where((leave) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          leave.leaveId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          leave.reason.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == null || leave.status == _statusFilter;

      // Type filter
      final matchesType = _typeFilter == null || leave.leaveType == _typeFilter;

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  // Get pending leaves
  List<Leave> getPendingLeaves() {
    return _leaves.where((l) => l.status == 'pending').toList();
  }

  // Get approved leaves
  List<Leave> getApprovedLeaves() {
    return _leaves.where((l) => l.status == 'approved').toList();
  }

  // Get active leaves (currently ongoing)
  List<Leave> getActiveLeaves() {
    final now = DateTime.now();
    return _leaves.where((leave) => 
      leave.status == 'approved' &&
      leave.fromDate.isBefore(now) &&
      leave.toDate.isAfter(now)
    ).toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total': _leaves.length,
      'pending': _leaves.where((l) => l.status == 'pending').length,
      'approved': _leaves.where((l) => l.status == 'approved').length,
      'rejected': _leaves.where((l) => l.status == 'rejected').length,
      'active': getActiveLeaves().length,
    };
  }
}
