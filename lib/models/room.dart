import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType {
  single,
  double,
  triple,
  quad;

  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Single';
      case RoomType.double:
        return 'Double';
      case RoomType.triple:
        return 'Triple';
      case RoomType.quad:
        return 'Quad';
    }
  }

  static RoomType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'single':
        return RoomType.single;
      case 'double':
        return RoomType.double;
      case 'triple':
        return RoomType.triple;
      case 'quad':
        return RoomType.quad;
      default:
        return RoomType.double;
    }
  }
}

class Room {
  final String roomId;
  final String hostelId;
  final String roomNumber;
  final RoomType type;
  final int capacity;
  final List<String> occupants;
  final String status;
  final String? floor;
  final String? block;

  int get currentOccupancy => occupants.length;

  Room({
    required this.roomId,
    required this.hostelId,
    required this.roomNumber,
    required this.type,
    required this.capacity,
    this.occupants = const [],
    this.status = 'available',
    this.floor,
    this.block,
  });

  bool get isAvailable => occupants.length < capacity && status == 'available';
  int get availableBeds => capacity - occupants.length;

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      roomId: doc.id,
      hostelId: data['hostelId'] ?? '',
      roomNumber: data['roomNumber'] ?? '',
      type: RoomType.fromString(data['type'] ?? 'double'),
      capacity: data['capacity'] ?? 2,
      occupants: List<String>.from(data['occupants'] ?? []),
      status: data['status'] ?? 'available',
      floor: data['floor'],
      block: data['block'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hostelId': hostelId,
      'roomNumber': roomNumber,
      'type': type.name,
      'capacity': capacity,
      'occupants': occupants,
      'status': status,
      'floor': floor,
      'block': block,
    };
  }

  Room copyWith({
    String? hostelId,
    String? roomNumber,
    RoomType? type,
    int? capacity,
    List<String>? occupants,
    String? status,
    String? floor,
    String? block,
  }) {
    return Room(
      roomId: roomId,
      hostelId: hostelId ?? this.hostelId,
      roomNumber: roomNumber ?? this.roomNumber,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      occupants: occupants ?? this.occupants,
      status: status ?? this.status,
      floor: floor ?? this.floor,
      block: block ?? this.block,
    );
  }
}
