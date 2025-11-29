import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_text_field.dart';

class EditStudentScreen extends StatefulWidget {
  final Student student;

  const EditStudentScreen({super.key, required this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _courseController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _semesterController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _bloodGroupController;

  String? _selectedGender;
  DateTime? _dateOfBirth;
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phoneNumber ?? '');
    _courseController = TextEditingController(text: widget.student.course ?? '');
    _departmentController = TextEditingController(text: widget.student.department ?? '');
    _yearController = TextEditingController(text: widget.student.year?.toString() ?? '');
    _semesterController = TextEditingController(text: widget.student.semester?.toString() ?? '');
    _guardianNameController = TextEditingController(text: widget.student.guardianName ?? '');
    _guardianPhoneController = TextEditingController(text: widget.student.guardianPhone ?? '');
    _addressController = TextEditingController(text: widget.student.address ?? '');
    _bloodGroupController = TextEditingController(text: widget.student.bloodGroup ?? '');

    _selectedGender = widget.student.gender;
    _dateOfBirth = widget.student.dateOfBirth;
    _status = widget.student.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _semesterController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _addressController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'course': _courseController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.isNotEmpty ? int.tryParse(_yearController.text) : null,
        'semester': _semesterController.text.isNotEmpty ? int.tryParse(_semesterController.text) : null,
        'guardianName': _guardianNameController.text.trim(),
        'guardianPhone': _guardianPhoneController.text.trim(),
        'address': _addressController.text.trim(),
        'bloodGroup': _bloodGroupController.text.trim(),
        'gender': _selectedGender,
        'dateOfBirth': _dateOfBirth,
        'status': _status,
        'updatedAt': DateTime.now(),
      };

      await _dbService.updateStudent(widget.student.studentId, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student'),
        backgroundColor: AppColors.adminColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _emailController,
              label: 'Email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: false, // Email cannot be changed
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            // Date of Birth
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                ),
                child: Text(
                  _dateOfBirth != null
                      ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                      : 'Select date',
                  style: TextStyle(
                    color: _dateOfBirth != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            // Gender
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              items: ['Male', 'Female', 'Other'].map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _bloodGroupController,
              label: 'Blood Group',
              prefixIcon: Icons.bloodtype,
              hint: 'e.g., A+, O-, B+',
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Academic Information
            const Text(
              'Academic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _courseController,
              label: 'Course',
              prefixIcon: Icons.school,
              hint: 'e.g., B.Tech, M.Sc',
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _departmentController,
              label: 'Department',
              prefixIcon: Icons.business,
              hint: 'e.g., Computer Science',
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: _yearController,
                    label: 'Year',
                    prefixIcon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    hint: '1-4',
                  ),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                Expanded(
                  child: ModernTextField(
                    controller: _semesterController,
                    label: 'Semester',
                    prefixIcon: Icons.timeline,
                    keyboardType: TextInputType.number,
                    hint: '1-8',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Guardian Information
            const Text(
              'Guardian Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _guardianNameController,
              label: 'Guardian Name',
              prefixIcon: Icons.family_restroom,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _guardianPhoneController,
              label: 'Guardian Phone',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            ModernTextField(
              controller: _addressController,
              label: 'Address',
              prefixIcon: Icons.location_on,
              maxLines: 3,
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // Status
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: 'Student Status',
                prefixIcon: const Icon(Icons.check_circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
              items: ['active', 'inactive', 'archived', 'suspended'].map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _status = value!);
              },
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Save Button
            ModernButton(
              label: 'Save Changes',
              onPressed: _isLoading ? null : _saveChanges,
              loading: _isLoading,
              fullWidth: true,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
