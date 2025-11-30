import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_card.dart';

class FixStudentUidsScreen extends StatefulWidget {
  const FixStudentUidsScreen({super.key});

  @override
  State<FixStudentUidsScreen> createState() => _FixStudentUidsScreenState();
}

class _FixStudentUidsScreenState extends State<FixStudentUidsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isScanning = false;
  List<Map<String, dynamic>> _studentsWithoutUid = [];
  List<Map<String, dynamic>> _usersWithoutStudent = [];

  @override
  void initState() {
    super.initState();
    _scanForIssues();
  }

  Future<void> _scanForIssues() async {
    setState(() => _isScanning = true);

    try {
      // Find students without UID or with empty UID
      final studentsSnapshot = await _firestore.collection('students').get();
      final studentsWithoutUid = <Map<String, dynamic>>[];

      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final uid = data['uid'];
        if (uid == null || uid.toString().isEmpty) {
          studentsWithoutUid.add({
            'studentId': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? 'No email',
          });
        }
      }

      // Find users with student role but no student record
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final usersWithoutStudent = <Map<String, dynamic>>[];

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final uid = userDoc.id;

        // Check if student record exists with this UID
        final studentQuery = await _firestore
            .collection('students')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();

        if (studentQuery.docs.isEmpty) {
          usersWithoutStudent.add({
            'uid': uid,
            'name': userData['name'] ?? 'Unknown',
            'email': userData['email'] ?? 'No email',
          });
        }
      }

      if (mounted) {
        setState(() {
          _studentsWithoutUid = studentsWithoutUid;
          _usersWithoutStudent = usersWithoutStudent;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _linkStudentToUser(String studentId, String uid) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('students').doc(studentId).update({
        'uid': uid,
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully linked student to user account'),
            backgroundColor: AppColors.success,
          ),
        );
        await _scanForIssues();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error linking: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showLinkDialog(Map<String, dynamic> student) async {
    // Get all users with student role
    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    if (!mounted) return;

    final selectedUid = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Link ${student['name']} to User Account'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select a user account to link with this student:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: usersSnapshot.docs.map((userDoc) {
                      final userData = userDoc.data();
                      return ListTile(
                        title: Text(userData['name'] ?? 'Unknown'),
                        subtitle: Text(userData['email'] ?? 'No email'),
                        onTap: () => Navigator.pop(context, userDoc.id),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedUid != null) {
      await _linkStudentToUser(student['studentId'], selectedUid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fix Student-User Links'),
        backgroundColor: AppColors.adminColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForIssues,
            tooltip: 'Rescan',
          ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              children: [
                // Header
                ModernCard(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _studentsWithoutUid.isEmpty && _usersWithoutStudent.isEmpty
                                ? Icons.check_circle
                                : Icons.warning,
                            color: _studentsWithoutUid.isEmpty && _usersWithoutStudent.isEmpty
                                ? AppColors.success
                                : AppColors.warning,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Status',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _studentsWithoutUid.isEmpty && _usersWithoutStudent.isEmpty
                                      ? 'All student accounts are properly linked'
                                      : 'Found issues that need attention',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Students without UID
                if (_studentsWithoutUid.isNotEmpty) ...[
                  Text(
                    'Students Without User Account Link',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_studentsWithoutUid.length} student(s) found without a linked user account',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ..._studentsWithoutUid.map((student) => ModernCard(
                        margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.link_off,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'],
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    student['email'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _showLinkDialog(student),
                              icon: const Icon(Icons.link, size: 18),
                              label: const Text('Link'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSizes.paddingLarge),
                ],

                // Users without student record
                if (_usersWithoutStudent.isNotEmpty) ...[
                  Text(
                    'User Accounts Without Student Record',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_usersWithoutStudent.length} user account(s) have student role but no student record',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  ..._usersWithoutStudent.map((user) => ModernCard(
                        margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: const Icon(
                                Icons.person_off,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['name'],
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['email'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'UID: ${user['uid']}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: Text(
                                'Needs Student Record',
                                style: TextStyle(
                                  color: AppColors.info,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // All clear message
                if (_studentsWithoutUid.isEmpty && _usersWithoutStudent.isEmpty)
                  ModernCard(
                    padding: const EdgeInsets.all(AppSizes.paddingLarge),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: AppColors.success,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All Clear!',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All student accounts are properly linked to user accounts.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
