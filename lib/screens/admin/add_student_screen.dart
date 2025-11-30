import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _courseController = TextEditingController();
  final _departmentController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  String _hostelId = 'H1'; // Default hostel, should be fetched from settings

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNoController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    _departmentController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current admin email for re-authentication
      final authProvider = context.read<AuthProvider>();
      final adminEmail = authProvider.currentUser?.email;

      if (adminEmail == null) {
        throw Exception('Admin email not found');
      }

      // Create user account (this will sign in as the new user)
      final result = await _authService.createUserForAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: UserRole.student,
        hostelId: _hostelId,
        phoneNumber: _phoneController.text.trim(),
      );

      // Create student record while authenticated as the new student
      // (Firestore rules allow students to create their own record)
      final student = Student(
        studentId: '', // Will be auto-generated
        uid: result.user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        rollNo: _rollNoController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        hostelId: _hostelId,
        admissionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        course: _courseController.text.trim(),
        department: _departmentController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      await _dbService.createStudent(student);

      // Sign out the newly created student
      await _authService.signOut();

      // Re-authenticate as admin (will trigger auth state change)
      // The AuthProvider will handle the state update
      if (!mounted) return;

      // Show dialog to get admin password
      final adminPassword = await _showAdminPasswordDialog();

      if (adminPassword == null || adminPassword.isEmpty) {
        // If admin cancels, they're signed out but student is created
        // Navigate to login screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student created successfully. Please sign in again.'),
              backgroundColor: AppColors.warning,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
        return;
      }

      try {
        // Re-authenticate as admin
        await _authService.signIn(adminEmail, adminPassword);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student added successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Re-authentication failed, navigate to login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student created but re-authentication failed: ${e.toString()}. Please sign in.'),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _showAdminPasswordDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Admin Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your password to re-authenticate:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        backgroundColor: AppColors.adminColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // Info banner about re-authentication
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Note: After creating the student, you will need to re-enter your password to continue.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person,
              validator: Validators.validateName,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              prefixIcon: Icons.lock,
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
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
            CustomTextField(
              controller: _rollNoController,
              label: 'Roll Number',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter roll number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _courseController,
              label: 'Course',
              prefixIcon: Icons.school,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _departmentController,
              label: 'Department',
              prefixIcon: Icons.business,
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
            CustomTextField(
              controller: _guardianNameController,
              label: 'Guardian Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _guardianPhoneController,
              label: 'Guardian Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _addressController,
              label: 'Address',
              prefixIcon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveStudent,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Add Student'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
