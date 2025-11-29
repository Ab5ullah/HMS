import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../utils/constants.dart';
import '../admin/student_detail_screen.dart';

class WardenStudentOverviewScreen extends StatefulWidget {
  const WardenStudentOverviewScreen({super.key});

  @override
  State<WardenStudentOverviewScreen> createState() => _WardenStudentOverviewScreenState();
}

class _WardenStudentOverviewScreenState extends State<WardenStudentOverviewScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    await context.read<StudentProvider>().fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: AppColors.wardenColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCard(studentProvider),
          Expanded(
            child: studentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : studentProvider.students.isEmpty
                    ? const Center(child: Text('No students found'))
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingSmall),
                          itemCount: studentProvider.students.length,
                          itemBuilder: (context, index) {
                            final student = studentProvider.students[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.studentColor,
                                  child: Text(
                                    student.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(student.name),
                                subtitle: Text(
                                  '${student.course != null && student.department != null ? '${student.course} - ${student.department}' : student.course ?? student.department ?? 'Student'}\n${student.studentId}',
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(
                                    student.status.toUpperCase(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: student.status == 'active' 
                                      ? Colors.green 
                                      : Colors.grey,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentDetailScreen(student: student),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search students...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
          context.read<StudentProvider>().searchStudents(value);
        },
      ),
    );
  }

  Widget _buildStatsCard(StudentProvider provider) {
    final stats = provider.getStatistics();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Total', '${stats['total'] ?? 0}', Colors.blue),
            _buildStatItem('Active', '${stats['active'] ?? 0}', Colors.green),
            _buildStatItem('Inactive', '${stats['inactive'] ?? 0}', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
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
}
