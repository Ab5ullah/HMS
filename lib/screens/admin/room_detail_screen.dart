import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/loading_widget.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.room.roomNumber}'),
        backgroundColor: AppColors.wardenColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editRoom();
              } else if (value == 'maintenance') {
                _toggleMaintenance();
              } else if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Room'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'maintenance',
                child: Row(
                  children: [
                    Icon(
                      widget.room.status == 'maintenance'
                          ? Icons.build_circle
                          : Icons.build,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.room.status == 'maintenance'
                          ? 'Mark Available'
                          : 'Mark Maintenance',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Room', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  Icon(
                    Icons.meeting_room,
                    size: 60,
                    color: widget.room.isAvailable
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Room ${widget.room.roomNumber}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(widget.room.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Room Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Type',
            value: widget.room.type.displayName,
            icon: Icons.category,
          ),
          InfoCard(
            label: 'Capacity',
            value: '${widget.room.capacity} beds',
            icon: Icons.hotel,
          ),
          InfoCard(
            label: 'Occupancy',
            value: '${widget.room.occupants.length}/${widget.room.capacity}',
            icon: Icons.people,
            color: widget.room.isAvailable ? Colors.green : Colors.orange,
          ),
          if (widget.room.floor != null)
            InfoCard(
              label: 'Floor',
              value: widget.room.floor!,
              icon: Icons.layers,
            ),
          if (widget.room.block != null)
            InfoCard(
              label: 'Block',
              value: widget.room.block!,
              icon: Icons.business,
            ),
          const SizedBox(height: AppSizes.paddingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Occupants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.room.isAvailable)
                TextButton.icon(
                  onPressed: _allocateStudent,
                  icon: const Icon(Icons.add),
                  label: const Text('Allocate'),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildOccupantsList(),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'available':
        color = Colors.green;
        label = 'Available';
        break;
      case 'maintenance':
        color = Colors.red;
        label = 'Maintenance';
        break;
      default:
        color = Colors.orange;
        label = 'Full';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOccupantsList() {
    if (widget.room.occupants.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingLarge),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.bed, size: 50, color: Colors.grey),
                SizedBox(height: AppSizes.paddingSmall),
                Text('No occupants', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<List<Student?>>(
      future: Future.wait(
        widget.room.occupants.map(
          (studentId) => _dbService.getStudent(studentId),
        ),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        final students = snapshot.data?.whereType<Student>().toList() ?? [];

        return Column(
          children: students.map((student) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.studentColor,
                  child: Text(student.name[0].toUpperCase()),
                ),
                title: Text(student.name),
                subtitle: Text(student.email),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                  onPressed: () => _deallocateStudent(student),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _editRoom() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit feature coming soon')));
  }

  void _toggleMaintenance() async {
    final newStatus = widget.room.status == 'maintenance'
        ? 'available'
        : 'maintenance';

    try {
      await _dbService.updateRoom(widget.room.roomId, {'status': newStatus});

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room marked as $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    if (widget.room.occupants.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete room with occupants'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text(
          'Are you sure you want to delete Room ${widget.room.roomNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Delete room logic here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _allocateStudent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student allocation feature coming soon')),
    );
  }

  void _deallocateStudent(Student student) async {
    try {
      await _dbService.deallocateRoom(widget.room.roomId, student.studentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deallocated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the view
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
