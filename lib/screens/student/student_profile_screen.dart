import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../utils/constants.dart';
import '../../widgets/common/info_card.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.studentColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon!')),
              );
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildPersonalInfo(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildGuardianInfo(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildAcademicInfo(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.studentColor,
              child: Text(
                student.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              student.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Student ID: ${student.studentId}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildStatusChip(student.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'inactive':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildPersonalInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            InfoCard(
              label: 'Full Name',
              value: student.name,
              icon: Icons.person,
            ),
            if (student.dateOfBirth != null)
              InfoCard(
                label: 'Date of Birth',
                value:
                    '${student.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}',
                icon: Icons.cake,
              ),
            if (student.gender != null)
              InfoCard(
                label: 'Gender',
                value: student.gender!,
                icon: Icons.person_outline,
              ),
            if (student.bloodGroup != null)
              InfoCard(
                label: 'Blood Group',
                value: student.bloodGroup!,
                icon: Icons.bloodtype,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardianInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guardian Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            if (student.guardianName != null)
              InfoCard(
                label: 'Guardian Name',
                value: student.guardianName!,
                icon: Icons.person,
              ),
            if (student.guardianPhone != null)
              InfoCard(
                label: 'Guardian Phone',
                value: student.guardianPhone!,
                icon: Icons.phone,
              ),
            if (student.guardianRelation != null)
              InfoCard(
                label: 'Relation',
                value: student.guardianRelation!,
                icon: Icons.family_restroom,
              ),
            if (student.address != null)
              InfoCard(
                label: 'Address',
                value: student.address!,
                icon: Icons.location_on,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            if (student.course != null)
              InfoCard(
                label: 'Course',
                value: student.course!,
                icon: Icons.school,
              ),
            if (student.department != null)
              InfoCard(
                label: 'Department',
                value: student.department!,
                icon: Icons.business,
              ),
            if (student.year != null)
              InfoCard(
                label: 'Year',
                value: student.year.toString(),
                icon: Icons.calendar_today,
              ),
            if (student.semester != null)
              InfoCard(
                label: 'Semester',
                value: student.semester.toString(),
                icon: Icons.timeline,
              ),
            if (student.enrollmentDate != null)
              InfoCard(
                label: 'Enrollment Date',
                value:
                    '${student.enrollmentDate!.day}/${student.enrollmentDate!.month}/${student.enrollmentDate!.year}',
                icon: Icons.date_range,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            InfoCard(label: 'Email', value: student.email, icon: Icons.email),
            if (student.phoneNumber != null)
              InfoCard(
                label: 'Phone',
                value: student.phoneNumber!,
                icon: Icons.phone,
              ),
            if (student.roomId != null)
              InfoCard(label: 'Room', value: student.roomId!, icon: Icons.room),
          ],
        ),
      ),
    );
  }
}
