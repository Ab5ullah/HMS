import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'add_room_screen.dart';
import 'room_detail_screen.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
        backgroundColor: AppColors.wardenColor,
        automaticallyImplyLeading: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Room>>(
        stream: _dbService.getRooms(
          status: _statusFilter == 'all' || _statusFilter == 'full' ? null : _statusFilter,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplayWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {});
              },
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading rooms...');
          }

          var rooms = snapshot.data ?? [];

          // Apply client-side filter for 'full' rooms
          if (_statusFilter == 'full') {
            rooms = rooms.where((room) => !room.isAvailable).toList();
          }

          if (rooms.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.meeting_room,
              title: 'No rooms yet',
              message: 'Add your first room to get started',
              action: ElevatedButton.icon(
                onPressed: () => _navigateToAddRoom(),
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
              ),
            );
          }

          return ListView.builder(
            itemCount: rooms.length,
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomCard(room);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRoom(),
        backgroundColor: AppColors.wardenColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final isAvailable = room.isAvailable;
    final occupancyColor = isAvailable ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: occupancyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            Icons.meeting_room,
            color: occupancyColor,
            size: 30,
          ),
        ),
        title: Text(
          'Room ${room.roomNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Type: ${room.type.displayName}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: occupancyColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${room.occupants.length}/${room.capacity} occupied',
                  style: TextStyle(
                    color: occupancyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                if (!isAvailable)
                  const Chip(
                    label: Text('Full'),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )
                else
                  Chip(
                    label: Text('${room.availableBeds} beds available'),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(
                      fontSize: 10,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToRoomDetail(room),
        isThreeLine: true,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Rooms'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All'),
              value: 'all',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Available'),
              value: 'available',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Full'),
              value: 'full',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Maintenance'),
              value: 'maintenance',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddRoom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRoomScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToRoomDetail(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailScreen(room: room),
      ),
    );
  }
}
