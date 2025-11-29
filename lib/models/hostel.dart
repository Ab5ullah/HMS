import 'package:cloud_firestore/cloud_firestore.dart';

class Hostel {
  final String hostelId;
  final String name;
  final String address;
  final String? contactNumber;
  final String? email;
  final int totalRooms;
  final int totalCapacity;
  final double hostelFeePerMonth;
  final double messFeePerMeal;
  final String? wardenId;
  final String? messManagerId;

  Hostel({
    required this.hostelId,
    required this.name,
    required this.address,
    this.contactNumber,
    this.email,
    required this.totalRooms,
    required this.totalCapacity,
    required this.hostelFeePerMonth,
    required this.messFeePerMeal,
    this.wardenId,
    this.messManagerId,
  });

  factory Hostel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hostel(
      hostelId: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'],
      email: data['email'],
      totalRooms: data['totalRooms'] ?? 0,
      totalCapacity: data['totalCapacity'] ?? 0,
      hostelFeePerMonth: (data['hostelFeePerMonth'] ?? 0).toDouble(),
      messFeePerMeal: (data['messFeePerMeal'] ?? 0).toDouble(),
      wardenId: data['wardenId'],
      messManagerId: data['messManagerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'contactNumber': contactNumber,
      'email': email,
      'totalRooms': totalRooms,
      'totalCapacity': totalCapacity,
      'hostelFeePerMonth': hostelFeePerMonth,
      'messFeePerMeal': messFeePerMeal,
      'wardenId': wardenId,
      'messManagerId': messManagerId,
    };
  }
}
