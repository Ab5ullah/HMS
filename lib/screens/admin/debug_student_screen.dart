import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_card.dart';

/// Debug screen to check student-user account linking
class DebugStudentScreen extends StatefulWidget {
  const DebugStudentScreen({super.key});

  @override
  State<DebugStudentScreen> createState() => _DebugStudentScreenState();
}

class _DebugStudentScreenState extends State<DebugStudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Map<String, dynamic> _debugInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);

    try {
      // Get current auth user
      final authUser = _auth.currentUser;

      // Get all students
      final studentsSnapshot = await _firestore.collection('students').get();

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      final debugInfo = <String, dynamic>{
        'currentAuthUser': authUser != null
            ? {
                'uid': authUser.uid,
                'email': authUser.email,
                'displayName': authUser.displayName,
              }
            : null,
        'totalStudents': studentsSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        'students': studentsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'studentId': doc.id,
            'uid': data['uid'] ?? 'MISSING UID',
            'name': data['name'] ?? 'No name',
            'email': data['email'] ?? 'No email',
            'hasUid': data['uid'] != null && data['uid'].toString().isNotEmpty,
          };
        }).toList(),
        'studentUsers': usersSnapshot.docs
            .where((doc) => doc.data()['role'] == 'student')
            .map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'name': data['name'] ?? 'No name',
            'email': data['email'] ?? 'No email',
            'status': data['status'] ?? 'No status',
          };
        }).toList(),
      };

      // Find matching pairs
      final matchedPairs = <Map<String, dynamic>>[];
      final unmatchedStudents = <Map<String, dynamic>>[];
      final unmatchedUsers = <Map<String, dynamic>>[];

      for (var student in debugInfo['students'] as List) {
        final studentUid = student['uid'];
        if (studentUid == 'MISSING UID' || studentUid.toString().isEmpty) {
          unmatchedStudents.add(student);
          continue;
        }

        final matchingUser = (debugInfo['studentUsers'] as List).firstWhere(
          (user) => user['uid'] == studentUid,
          orElse: () => <String, dynamic>{},
        );

        if (matchingUser.isEmpty) {
          unmatchedStudents.add(student);
        } else {
          matchedPairs.add({
            'student': student,
            'user': matchingUser,
          });
        }
      }

      for (var user in debugInfo['studentUsers'] as List) {
        final userUid = user['uid'];
        final hasMatchingStudent = (debugInfo['students'] as List)
            .any((student) => student['uid'] == userUid);

        if (!hasMatchingStudent) {
          unmatchedUsers.add(user);
        }
      }

      debugInfo['matchedPairs'] = matchedPairs;
      debugInfo['unmatchedStudents'] = unmatchedStudents;
      debugInfo['unmatchedUsers'] = unmatchedUsers;

      if (mounted) {
        setState(() {
          _debugInfo = debugInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugInfo = {'error': e.toString()};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Student-User Links'),
        backgroundColor: AppColors.adminColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debugInfo.containsKey('error')
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error: ${_debugInfo['error']}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  children: [
                    // Current User Info
                    _buildSection(
                      'Current Authenticated User',
                      Icons.person,
                      AppColors.primary,
                      _debugInfo['currentAuthUser'] != null
                          ? [
                              _buildInfoRow('UID',
                                  _debugInfo['currentAuthUser']['uid']),
                              _buildInfoRow('Email',
                                  _debugInfo['currentAuthUser']['email']),
                              _buildInfoRow('Name',
                                  _debugInfo['currentAuthUser']['displayName'] ?? 'Not set'),
                            ]
                          : [const Text('No user authenticated')],
                    ),

                    const SizedBox(height: 16),

                    // Summary
                    _buildSection(
                      'Summary',
                      Icons.analytics,
                      AppColors.info,
                      [
                        _buildInfoRow('Total Students',
                            '${_debugInfo['totalStudents']}'),
                        _buildInfoRow('Total Users',
                            '${_debugInfo['totalUsers']}'),
                        _buildInfoRow('Student Users',
                            '${(_debugInfo['studentUsers'] as List).length}'),
                        _buildInfoRow('Matched Pairs',
                            '${(_debugInfo['matchedPairs'] as List).length}'),
                        _buildInfoRow('Unmatched Students',
                            '${(_debugInfo['unmatchedStudents'] as List).length}'),
                        _buildInfoRow('Unmatched Users',
                            '${(_debugInfo['unmatchedUsers'] as List).length}'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Matched Pairs
                    if ((_debugInfo['matchedPairs'] as List).isNotEmpty) ...[
                      _buildSection(
                        'Correctly Linked (${(_debugInfo['matchedPairs'] as List).length})',
                        Icons.check_circle,
                        AppColors.success,
                        (_debugInfo['matchedPairs'] as List).map((pair) {
                          return ModernCard(
                            margin: const EdgeInsets.only(
                                bottom: AppSizes.paddingSmall),
                            padding:
                                const EdgeInsets.all(AppSizes.paddingSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pair['student']['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Email: ${pair['student']['email']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'UID: ${pair['student']['uid']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Status: ${pair['user']['status']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: pair['user']['status'] == 'active'
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Unmatched Students
                    if ((_debugInfo['unmatchedStudents'] as List)
                        .isNotEmpty) ...[
                      _buildSection(
                        'Students WITHOUT User Link (${(_debugInfo['unmatchedStudents'] as List).length})',
                        Icons.warning,
                        AppColors.error,
                        (_debugInfo['unmatchedStudents'] as List).map((student) {
                          return ModernCard(
                            margin: const EdgeInsets.only(
                                bottom: AppSizes.paddingSmall),
                            padding:
                                const EdgeInsets.all(AppSizes.paddingSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.error,
                                        color: AppColors.error, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        student['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Email: ${student['email']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'UID: ${student['uid']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: student['hasUid']
                                        ? Colors.grey[600]
                                        : AppColors.error,
                                    fontWeight: student['hasUid']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Student ID: ${student['studentId']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Unmatched Users
                    if ((_debugInfo['unmatchedUsers'] as List).isNotEmpty) ...[
                      _buildSection(
                        'Users WITHOUT Student Record (${(_debugInfo['unmatchedUsers'] as List).length})',
                        Icons.person_off,
                        AppColors.warning,
                        (_debugInfo['unmatchedUsers'] as List).map((user) {
                          return ModernCard(
                            margin: const EdgeInsets.only(
                                bottom: AppSizes.paddingSmall),
                            padding:
                                const EdgeInsets.all(AppSizes.paddingSmall),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning,
                                        color: AppColors.warning, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        user['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Email: ${user['email']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'UID: ${user['uid']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Status: ${user['status']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: user['status'] == 'active'
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return ModernCard(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
