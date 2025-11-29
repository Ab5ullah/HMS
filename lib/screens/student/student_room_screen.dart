import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../models/student.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/student_provider.dart';
import '../../utils/constants.dart';

class StudentRoomScreen extends StatefulWidget {
  const StudentRoomScreen({super.key});

  @override
  State<StudentRoomScreen> createState() => _StudentRoomScreenState();
}

class _StudentRoomScreenState extends State<StudentRoomScreen> {
  Room? _room;
  List<Student> _roommates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final studentProvider = context.read<StudentProvider>();
    final roomProvider = context.read<RoomProvider>();
    final uid = authProvider.user?.uid;

    if (uid != null) {
      // Get student data
      final student = await studentProvider.getStudentByUid(uid);

      if (student?.roomId != null && mounted) {
        // Get room details
        final room = await roomProvider.getRoom(student!.roomId!);
        if (!mounted) return;
        setState(() => _room = room);

        // Get roommates - Fetch all students and filter by same roomId
        await studentProvider.fetchStudents();
        if (!mounted) return;
        final allStudents = studentProvider.students;
        final roommates = allStudents
            .where((s) => s.roomId == student.roomId && s.uid != uid)
            .toList();

        setState(() => _roommates = roommates);
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Room'),
        backgroundColor: AppColors.studentColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _room == null
              ? _buildNoRoomState()
              : RefreshIndicator(
                  onRefresh: _loadRoomDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRoomInfoCard(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildOccupancyCard(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildRoommatesSection(),
                        const SizedBox(height: AppSizes.paddingMedium),
                        _buildActionsSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildNoRoomState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bed_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No room assigned',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Please contact the administration',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfoCard() {
    return Card(
      color: AppColors.studentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            const Icon(Icons.meeting_room, size: 64, color: AppColors.studentColor),
            const SizedBox(height: 16),
            Text(
              'Room ${_room!.roomNumber}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Floor ${_room!.floor}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard() {
    final occupancyPercent = (_room!.currentOccupancy / _room!.capacity * 100).toInt();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Occupancy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOccupancyItem(
                  'Capacity',
                  _room!.capacity.toString(),
                  Icons.group,
                  Colors.blue,
                ),
                _buildOccupancyItem(
                  'Occupied',
                  _room!.currentOccupancy.toString(),
                  Icons.person,
                  Colors.green,
                ),
                _buildOccupancyItem(
                  'Available',
                  (_room!.capacity - _room!.currentOccupancy).toString(),
                  Icons.person_outline,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _room!.currentOccupancy / _room!.capacity,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                occupancyPercent > 80 ? Colors.orange : Colors.green,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text(
              '$occupancyPercent% Occupied',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRoommatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roommates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_roommates.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No other roommates',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._roommates.map((student) => ListTile(
                    leading: CircleAvatar(
                      child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : '?'),
                    ),
                    title: Text(student.name),
                    subtitle: Text(
                      student.course != null && student.department != null
                          ? '${student.course} - ${student.department}'
                          : student.course ?? student.department ?? 'Student',
                    ),
                    trailing: student.phoneNumber != null
                        ? const Icon(Icons.phone, size: 20)
                        : null,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maintenance request coming soon!')),
              );
            },
            icon: const Icon(Icons.build),
            label: const Text('Request Maintenance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room change request coming soon!')),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Request Room Change'),
          ),
        ),
      ],
    );
  }
}
