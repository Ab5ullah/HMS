import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/database_service.dart';

class PaymentProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Payment> _payments = [];
  List<Payment> _filteredPayments = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _typeFilter;

  // Getters
  List<Payment> get payments => _filteredPayments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all payments
  Future<void> fetchPayments({String? studentId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getPayments(studentId: studentId, status: status);
      final paymentsList = await stream.first;
      _payments = paymentsList;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _payments = [];
      _filteredPayments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      return await _dbService.getPayment(paymentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get payments for a student
  Future<List<Payment>> getStudentPayments(String studentId) async {
    try {
      final stream = _dbService.getPayments(studentId: studentId);
      return await stream.first;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Add new payment
  Future<bool> addPayment(Payment payment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createPayment(payment);
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update payment
  Future<bool> updatePayment(String paymentId, Map<String, dynamic> data) async {
    try {
      await _dbService.updatePayment(paymentId, data);
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Record payment transaction
  Future<bool> recordPayment(String paymentId, double amount) async {
    try {
      final payment = await getPayment(paymentId);
      if (payment == null) return false;

      final newPaidAmount = payment.paidAmount + amount;
      final newDueAmount = payment.totalAmount - newPaidAmount;
      final newStatus = newDueAmount <= 0 ? 'paid' : 'partial';

      await updatePayment(paymentId, {
        'paidAmount': newPaidAmount,
        'dueAmount': newDueAmount,
        'status': newStatus,
        'paidAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search payments
  void searchPayments(String query) {
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
    _filteredPayments = _payments.where((payment) {
      // Search filter (would need student name - simplified for now)
      final matchesSearch = _searchQuery.isEmpty ||
          payment.paymentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          payment.studentId.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == null || payment.status == _statusFilter;

      // Type filter  
      final matchesType = _typeFilter == null || payment.type == _typeFilter;

      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  // Get overdue payments
  List<Payment> getOverduePayments() {
    final now = DateTime.now();
    return _payments.where((payment) => 
      payment.status != 'paid' && 
      payment.dueDate.isBefore(now)
    ).toList();
  }

  // Get pending payments
  List<Payment> getPendingPayments() {
    return _payments.where((payment) => payment.status == 'pending').toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalAmount = _payments.fold<double>(0, (sum, p) => sum + p.totalAmount);
    final totalPaid = _payments.fold<double>(0, (sum, p) => sum + p.paidAmount);
    final totalDue = _payments.fold<double>(0, (sum, p) => sum + (p.totalAmount - p.paidAmount));
    
    return {
      'total': _payments.length,
      'pending': _payments.where((p) => p.status == 'pending').length,
      'partial': _payments.where((p) => p.status == 'partial').length,
      'paid': _payments.where((p) => p.status == 'paid').length,
      'overdue': getOverduePayments().length,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'totalDue': totalDue,
    };
  }
}
