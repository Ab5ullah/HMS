import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../services/database_service.dart';

class RoomProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _floorFilter;

  // Getters
  List<Room> get rooms => _filteredRooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all rooms
  Future<void> fetchRooms({String? hostelId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stream = _dbService.getRooms(hostelId: hostelId, status: status);
      final roomsList = await stream.first;
      _rooms = roomsList;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _rooms = [];
      _filteredRooms = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get room by ID
  Future<Room?> getRoom(String roomId) async {
    try {
      return await _dbService.getRoom(roomId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Add new room
  Future<bool> addRoom(Room room) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dbService.createRoom(room);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await _dbService.updateRoom(roomId, data);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Allocate room to student
  Future<bool> allocateRoom(String roomId, String studentId) async {
    try {
      await _dbService.allocateRoom(roomId, studentId);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Deallocate room from student
  Future<bool> deallocateRoom(String roomId, String studentId) async {
    try {
      await _dbService.deallocateRoom(roomId, studentId);
      await fetchRooms();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Search rooms
  void searchRooms(String query) {
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

  // Filter by floor
  void filterByFloor(String? floor) {
    _floorFilter = floor;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _floorFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    _filteredRooms = _rooms.where((room) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          room.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filter
      final matchesStatus = _statusFilter == null || room.status == _statusFilter;

      // Floor filter
      final matchesFloor = _floorFilter == null || room.floor == _floorFilter;

      return matchesSearch && matchesStatus && matchesFloor;
    }).toList();
  }

  // Get available rooms
  List<Room> getAvailableRooms() {
    return _rooms.where((room) => 
      room.status == 'available' && 
      room.occupants.length < room.capacity
    ).toList();
  }

  // Get rooms by floor
  // Get rooms by floor
  Map<String, List<Room>> getRoomsByFloor() {
    final Map<String, List<Room>> roomsByFloor = {};
    for (var room in _rooms) {
      final floor = room.floor ?? '0';
      if (!roomsByFloor.containsKey(floor)) {
        roomsByFloor[floor] = [];
      }
      roomsByFloor[floor]!.add(room);
    }
    return roomsByFloor;
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final totalCapacity = _rooms.fold<int>(0, (sum, room) => sum + room.capacity);
    final totalOccupied = _rooms.fold<int>(0, (sum, room) => sum + room.occupants.length);
    
    return {
      'total': _rooms.length,
      'available': _rooms.where((r) => r.status == 'available').length,
      'occupied': _rooms.where((r) => r.status == 'occupied').length,
      'maintenance': _rooms.where((r) => r.status == 'maintenance').length,
      'totalCapacity': totalCapacity,
      'totalOccupied': totalOccupied,
      'occupancyRate': totalCapacity > 0 ? (totalOccupied / totalCapacity * 100).toStringAsFixed(1) : '0',
    };
  }
}
