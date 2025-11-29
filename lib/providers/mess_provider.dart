import 'package:flutter/foundation.dart';
import '../models/mess.dart';
import '../services/database_service.dart';

class MessProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<MessMenu> _menus = [];
  List<MessAttendance> _attendance = [];
  List<MessInventory> _inventory = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<MessMenu> get menus => _menus;
  List<MessAttendance> get attendance => _attendance;
  List<MessInventory> get inventory => _inventory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch mess menus
  Future<void> fetchMenus({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getMessMenus(
        startDate: startDate,
        endDate: endDate,
      );
      _menus = await stream.first;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _menus = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get menu for specific date
  Future<MessMenu?> getMenuForDate(DateTime date) async {
    try {
      final menu = await _dbService.getMessMenuByDate(date);
      return menu;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get today's menu
  Future<MessMenu?> getTodayMenu() async {
    return await getMenuForDate(DateTime.now());
  }

  // Get week's menu
  Future<List<MessMenu>> getWeekMenu() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    await fetchMenus(startDate: startOfWeek, endDate: endOfWeek);
    return _menus;
  }

  // Create or update menu
  Future<bool> saveMenu(MessMenu menu) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createMessMenu(menu);
      await fetchMenus();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update menu
  Future<bool> updateMenu(String menuId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateMessMenu(menuId, data);
      await fetchMenus();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch mess attendance
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
      final stream = _dbService.getMessAttendance(
        studentId: studentId,
        date: date,
        startDate: startDate,
        endDate: endDate,
      );
      _attendance = await stream.first;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _attendance = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark mess attendance
  Future<bool> markAttendance(MessAttendance attendance) async {
    try {
      await _dbService.createMessAttendance(attendance);
      await fetchAttendance();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch inventory
  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getMessInventory();
      _inventory = await stream.first;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _inventory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add inventory item
  Future<bool> addInventoryItem(MessInventory item) async {
    try {
      await _dbService.createMessInventory(item);
      await fetchInventory();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update inventory item
  Future<bool> updateInventoryItem(
    String inventoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _dbService.updateMessInventory(inventoryId, data);
      await fetchInventory();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get low stock items
  List<MessInventory> getLowStockItems() {
    return _inventory
        .where((item) => item.quantity <= item.minimumStock)
        .toList();
  }

  // Get attendance statistics
  Map<String, dynamic> getAttendanceStatistics() {
    final todayAttendance = _attendance.where((a) => _isToday(a.date)).toList();

    return {
      'total': _attendance.length,
      'todayTotal': todayAttendance.length,
      'breakfast': todayAttendance
          .where((a) => a.mealType == 'breakfast')
          .length,
      'lunch': todayAttendance.where((a) => a.mealType == 'lunch').length,
      'dinner': todayAttendance.where((a) => a.mealType == 'dinner').length,
    };
  }

  // Get inventory statistics
  Map<String, dynamic> getInventoryStatistics() {
    return {
      'total': _inventory.length,
      'lowStock': getLowStockItems().length,
      'outOfStock': _inventory.where((i) => i.quantity == 0).length,
    };
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
