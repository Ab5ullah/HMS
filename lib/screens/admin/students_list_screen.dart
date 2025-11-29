import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: AppColors.adminColor,
        automaticallyImplyLeading: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _dbService.getStudents(
                status: _statusFilter == 'all' ? null : _statusFilter,
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
                  return const LoadingWidget(message: 'Loading students...');
                }

                final students = snapshot.data ?? [];
                final filteredStudents = students.where((student) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      student.name.toLowerCase().contains(_searchQuery) ||
                      student.email.toLowerCase().contains(_searchQuery) ||
                      (student.studentId.toLowerCase().contains(_searchQuery));
                  return matchesSearch;
                }).toList();

                if (filteredStudents.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: _searchQuery.isEmpty
                        ? 'No students yet'
                        : 'No students found',
                    message: _searchQuery.isEmpty
                        ? 'Add your first student to get started'
                        : 'Try adjusting your search or filters',
                    action: _searchQuery.isEmpty
                        ? ElevatedButton.icon(
                            onPressed: () => _navigateToAddStudent(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Student'),
                          )
                        : null,
                  );
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentCard(student);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddStudent(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.studentColor,
          backgroundImage:
              student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
          child: student.photoUrl == null
              ? Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(student.status),
                const SizedBox(width: 8),
                if (student.roomId != null)
                  Chip(
                    label: Text('Room: ${student.roomId}'),
                    backgroundColor: AppColors.wardenColor.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(fontSize: 12),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToStudentDetail(student),
        isThreeLine: true,
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
      case 'inactive':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Students'),
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
              title: const Text('Active'),
              value: 'active',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Graduated'),
              value: 'graduated',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Left'),
              value: 'left',
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Inactive'),
              value: 'inactive',
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

  void _navigateToAddStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToStudentDetail(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailScreen(student: student),
      ),
    );
  }
}
