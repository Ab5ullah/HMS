import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/info_card.dart';
import 'edit_student_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: AppColors.adminColor,
        automaticallyImplyLeading: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to edit screen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStudentScreen(student: widget.student),
                ),
              );

              if (result == true && mounted) {
                // Refresh the screen by popping and letting parent refresh
                Navigator.pop(context, true);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete();
              } else if (value == 'archive') {
                _archiveStudent();
              } else if (value == 'change_status') {
                _showChangeStatusDialog();
              } else if (value == 'allocate_room') {
                _showAllocateRoomDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'allocate_room',
                child: Row(
                  children: [
                    Icon(Icons.meeting_room, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Allocate Room'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'change_status',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Change Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Archive Student'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Student', style: TextStyle(color: Colors.red)),
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
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.studentColor,
                  backgroundImage: widget.student.photoUrl != null
                      ? NetworkImage(widget.student.photoUrl!)
                      : null,
                  child: widget.student.photoUrl == null
                      ? Text(
                          widget.student.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Text(
                  widget.student.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.student.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                _buildStatusChip(widget.student.status),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Phone Number',
            value: widget.student.phoneNumber ?? 'Not provided',
            icon: Icons.phone,
          ),
          InfoCard(
            label: 'Address',
            value: widget.student.address ?? 'Not provided',
            icon: Icons.location_on,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Course',
            value: widget.student.course ?? 'Not specified',
            icon: Icons.school,
          ),
          InfoCard(
            label: 'Department',
            value: widget.student.department ?? 'Not specified',
            icon: Icons.business,
          ),
          InfoCard(
            label: 'Admission Date',
            value: AppDateUtils.formatDate(widget.student.admissionDate),
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Guardian Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Guardian Name',
            value: widget.student.guardianName ?? 'Not provided',
            icon: Icons.person_outline,
          ),
          InfoCard(
            label: 'Guardian Phone',
            value: widget.student.guardianPhone ?? 'Not provided',
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Hostel Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Room Number',
            value: widget.student.roomId ?? 'Not allocated',
            icon: Icons.meeting_room,
          ),
          InfoCard(
            label: 'Hostel ID',
            value: widget.student.hostelId,
            icon: Icons.home_work,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'graduated':
        color = Colors.blue;
        break;
      case 'left':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
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
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showChangeStatusDialog() {
    String selectedStatus = widget.student.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Student Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select new status for ${widget.student.name}:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Active'),
                subtitle: const Text('Student is currently enrolled'),
                value: 'active',
                groupValue: selectedStatus,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Graduated'),
                subtitle: const Text('Student has completed their studies'),
                value: 'graduated',
                groupValue: selectedStatus,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Left'),
                subtitle: const Text('Student has left the hostel'),
                value: 'left',
                groupValue: selectedStatus,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Inactive'),
                subtitle: const Text('Student is temporarily inactive'),
                value: 'inactive',
                groupValue: selectedStatus,
                activeColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStudentStatus(selectedStatus);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStudentStatus(String newStatus) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
      };

      // If status is graduated or left, set the graduation date
      if (newStatus == 'graduated' || newStatus == 'left') {
        updateData['graduationDate'] = DateTime.now();
      } else {
        // If status is changed back to active or inactive, clear graduation date
        updateData['graduationDate'] = null;
      }

      await _dbService.updateStudent(widget.student.studentId, updateData);

      if (mounted) {
        // Update the local student object
        setState(() {
          // Force rebuild to show new status
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );

        // Pop and return to refresh the list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );
      }
    }
  }

  void _showAllocateRoomDialog() {
    String? selectedRoomId = widget.student.roomId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Allocate Room'),
          content: StreamBuilder<List<dynamic>>(
            stream: _dbService.getRooms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No rooms available');
              }

              final rooms = snapshot.data!;
              final availableRooms = rooms.where((r) =>
                r.status == 'available' || r.roomId == widget.student.roomId
              ).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select room for ${widget.student.name}:',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (widget.student.roomId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Current: ${widget.student.roomId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (widget.student.roomId != null)
                            RadioListTile<String?>(
                              title: const Text('Deallocate Room'),
                              subtitle: const Text('Remove room allocation'),
                              value: null,
                              groupValue: selectedRoomId,
                              activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  selectedRoomId = value;
                                });
                              },
                            ),
                          ...availableRooms.map((room) => RadioListTile<String?>(
                                title: Text('Room ${room.roomNumber}'),
                                subtitle: Text(
                                  'Floor: ${room.floor} | Capacity: ${room.currentOccupancy}/${room.capacity}',
                                ),
                                value: room.roomId,
                                groupValue: selectedRoomId,
                                activeColor: AppColors.primary,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRoomId = value;
                                  });
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _allocateRoom(selectedRoomId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Allocate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _allocateRoom(String? roomId) async {
    try {
      await _dbService.updateStudent(widget.student.studentId, {
        'roomId': roomId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              roomId != null
                  ? 'Room allocated successfully'
                  : 'Room deallocated successfully',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );

        // Pop and return to refresh
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${widget.student.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStudent() async {
    try {
      await _dbService.deleteStudent(widget.student.studentId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
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

  void _archiveStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Student'),
        content: const Text(
          'This will mark the student as graduated/left and move them to archives.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performArchive();
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  Future<void> _performArchive() async {
    try {
      await _dbService.updateStudent(widget.student.studentId, {
        'status': 'graduated',
        'graduationDate': DateTime.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student archived successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
