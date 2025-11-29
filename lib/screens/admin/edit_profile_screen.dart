import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/modern_text_field.dart';
import '../../widgets/common/modern_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw Exception('User not found');

      final authProvider = context.read<AuthProvider>();

      await _dbService.updateUser(user.uid, {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      });

      // Reload user data
      if (mounted) {
        await authProvider.reloadUser();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
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

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: EdgeInsets.all(context.responsivePadding),
              children: [
                ModernCard(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSizes.paddingSmall),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingSmall),
                          Text(
                            'Personal Information',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),

                      ModernTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        required: true,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Name'),
                      ),

                      const SizedBox(height: AppSizes.paddingMedium),

                      ModernTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Email cannot be changed',
                        prefixIcon: Icons.email_outlined,
                        enabled: false,
                      ),

                      const SizedBox(height: AppSizes.paddingMedium),

                      ModernTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter your phone number (optional)',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXLarge),

                Row(
                  children: [
                    if (!isMobile) ...[
                      Expanded(
                        child: ModernButton(
                          label: 'Cancel',
                          variant: ModernButtonVariant.outlined,
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          size: ModernButtonSize.large,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                    ],
                    Expanded(
                      flex: isMobile ? 1 : 2,
                      child: ModernButton(
                        label: 'Save Changes',
                        icon: Icons.check_circle_rounded,
                        onPressed: _isLoading ? null : _saveProfile,
                        color: AppColors.primary,
                        size: ModernButtonSize.large,
                        loading: _isLoading,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
