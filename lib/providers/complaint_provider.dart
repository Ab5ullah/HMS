import 'package:flutter/foundation.dart';
import '../models/complaint.dart';
import '../services/database_service.dart';

class ComplaintProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _categoryFilter;
  String? _priorityFilter;

  // Getters
  List<Complaint> get complaints => _filteredComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all complaints
  Future<void> fetchComplaints({
    String? studentId,
    String? status,
    String? category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getComplaints(
        studentId: studentId,
        status: status,
        category: category,
      );
      final complaintsList = await stream.first;
      _complaints = complaintsList;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _complaints = [];
      _filteredComplaints = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get complaint by ID
  Future<Complaint?> getComplaint(String complaintId) async {
    try {
      // Find in cached list first
      final complaint = _complaints.where((c) => c.complaintId == complaintId).firstOrNull;
      return complaint;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get complaints for a student
  Future<List<Complaint>> getStudentComplaints(String studentId) async {
    try {
      final stream = _dbService.getComplaints(studentId: studentId);
      return await stream.first;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Add new complaint
  Future<bool> addComplaint(Complaint complaint) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createComplaint(complaint);
      await fetchComplaints();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update complaint
  Future<bool> updateComplaint(String complaintId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateComplaint(complaintId, data);
      await fetchComplaints();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Resolve complaint
  Future<bool> resolveComplaint(String complaintId, String response) async {
    try {
      await updateComplaint(complaintId, {
        'status': 'resolved',
        'response': response,
        'resolvedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update complaint status
  Future<bool> updateComplaintStatus(String complaintId, String status) async {
    try {
      await updateComplaint(complaintId, {'status': status});
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search complaints
  void searchComplaints(String query) {
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

  // Filter by category
  void filterByCategory(String? category) {
    _categoryFilter = category;
    _applyFilters();
    notifyListeners();
  }

  // Filter by priority
  void filterByPriority(String? priority) {
    _priorityFilter = priority;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    _priorityFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    _filteredComplaints = _complaints.where((complaint) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          complaint.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          complaint.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          complaint.complaintId.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == null || complaint.status == _statusFilter;

      // Category filter
      final matchesCategory = _categoryFilter == null || complaint.category == _categoryFilter;

      // Priority filter
      final matchesPriority = _priorityFilter == null || complaint.priority == _priorityFilter;

      return matchesSearch && matchesStatus && matchesCategory && matchesPriority;
    }).toList();
  }

  // Get pending complaints
  List<Complaint> getPendingComplaints() {
    return _complaints.where((c) => c.status == 'pending').toList();
  }

  // Get high priority complaints
  List<Complaint> getHighPriorityComplaints() {
    return _complaints.where((c) => 
      c.priority == 'high' || c.priority == 'urgent'
    ).toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'total': _complaints.length,
      'pending': _complaints.where((c) => c.status == 'pending').length,
      'inProgress': _complaints.where((c) => c.status == 'in-progress').length,
      'resolved': _complaints.where((c) => c.status == 'resolved').length,
      'closed': _complaints.where((c) => c.status == 'closed').length,
      'urgent': _complaints.where((c) => c.priority == 'urgent').length,
      'high': _complaints.where((c) => c.priority == 'high').length,
    };
  }
}
