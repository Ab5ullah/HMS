import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType {
  breakfast,
  lunch,
  dinner;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  static MealType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      default:
        return MealType.lunch;
    }
  }
}

class MessMenu {
  final String menuId;
  final DateTime date;
  final String mealType;
  final List<String> items;
  final String breakfast;
  final String lunch;
  final String dinner;
  final String? breakfastDescription;
  final String? lunchDescription;
  final String? dinnerDescription;

  MessMenu({
    required this.menuId,
    required this.date,
    this.mealType = 'all',
    this.items = const [],
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    this.breakfastDescription,
    this.lunchDescription,
    this.dinnerDescription,
  });

  factory MessMenu.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessMenu(
      menuId: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      mealType: data['mealType'] ?? 'all',
      items: List<String>.from(data['items'] ?? []),
      breakfast: data['breakfast'] ?? '',
      lunch: data['lunch'] ?? '',
      dinner: data['dinner'] ?? '',
      breakfastDescription: data['breakfastDescription'],
      lunchDescription: data['lunchDescription'],
      dinnerDescription: data['dinnerDescription'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'mealType': mealType,
      'items': items,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'breakfastDescription': breakfastDescription,
      'lunchDescription': lunchDescription,
      'dinnerDescription': dinnerDescription,
    };
  }
}

class MessAttendance {
  final String attendanceId;
  final String studentId;
  final MealType mealType;
  final DateTime date;
  final String status;
  final String? remarks;

  MessAttendance({
    required this.attendanceId,
    required this.studentId,
    required this.mealType,
    required this.date,
    this.status = 'present',
    this.remarks,
  });

  factory MessAttendance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessAttendance(
      attendanceId: doc.id,
      studentId: data['studentId'] ?? '',
      mealType: MealType.fromString(data['mealType'] ?? 'lunch'),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'present',
      remarks: data['remarks'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'mealType': mealType.name,
      'date': Timestamp.fromDate(date),
      'status': status,
      'remarks': remarks,
    };
  }
}

class MessInventory {
  final String itemId;
  final String itemName;
  final double quantity;
  final String unit;
  final double minimumStock;
  final DateTime lastUpdated;

  // Aliases for compatibility
  double get currentQuantity => quantity;
  double get minimumQuantity => minimumStock;

  MessInventory({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.minimumStock,
    required this.lastUpdated,
  });

  bool get isLowStock => quantity <= minimumStock;

  factory MessInventory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessInventory(
      itemId: doc.id,
      itemName: data['itemName'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'kg',
      minimumStock: (data['minimumStock'] ?? data['minimumQuantity'] ?? 0).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'unit': unit,
      'minimumStock': minimumStock,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
