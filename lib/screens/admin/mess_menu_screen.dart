import 'package:flutter/material.dart';
import '../../models/mess.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/custom_text_field.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({super.key});

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Menu'),
        backgroundColor: AppColors.messManagerColor,
        automaticallyImplyLeading: context.isMobile,
      ),
      body: StreamBuilder<List<MessMenu>>(
        stream: _dbService.getMessMenus(),
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
            return const LoadingWidget(message: 'Loading menu...');
          }

          final menus = snapshot.data ?? [];

          if (menus.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.restaurant_menu,
              title: 'No menu items',
              message: 'No menu items found',
            );
          }

          return ListView.builder(
            itemCount: menus.length,
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemBuilder: (context, index) {
              final menu = menus[index];
              return _buildMenuCard(menu);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuDialog(),
        backgroundColor: AppColors.messManagerColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuCard(MessMenu menu) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(menu.date),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditMenuDialog(menu),
                ),
              ],
            ),
            const Divider(),
            _buildMealSection('Breakfast', menu.breakfast, menu.breakfastDescription),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildMealSection('Lunch', menu.lunch, menu.lunchDescription),
            const SizedBox(height: AppSizes.paddingSmall),
            _buildMealSection('Dinner', menu.dinner, menu.dinnerDescription),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String mealType, String items, String? description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mealType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.messManagerColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(items),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddMenuDialog() {
    final breakfastController = TextEditingController();
    final lunchController = TextEditingController();
    final dinnerController = TextEditingController();
    final breakfastDescController = TextEditingController();
    final lunchDescController = TextEditingController();
    final dinnerDescController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Menu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: breakfastController,
                  label: 'Breakfast',
                  prefixIcon: Icons.free_breakfast,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: breakfastDescController,
                  label: 'Breakfast Description (Optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: lunchController,
                  label: 'Lunch',
                  prefixIcon: Icons.lunch_dining,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: lunchDescController,
                  label: 'Lunch Description (Optional)',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: dinnerController,
                  label: 'Dinner',
                  prefixIcon: Icons.dinner_dining,
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: dinnerDescController,
                  label: 'Dinner Description (Optional)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (breakfastController.text.isEmpty ||
                    lunchController.text.isEmpty ||
                    dinnerController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all meal fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final menu = MessMenu(
                    menuId: '',
                    date: selectedDate,
                    breakfast: breakfastController.text.trim(),
                    lunch: lunchController.text.trim(),
                    dinner: dinnerController.text.trim(),
                    breakfastDescription: breakfastDescController.text.trim().isNotEmpty
                        ? breakfastDescController.text.trim()
                        : null,
                    lunchDescription: lunchDescController.text.trim().isNotEmpty
                        ? lunchDescController.text.trim()
                        : null,
                    dinnerDescription: dinnerDescController.text.trim().isNotEmpty
                        ? dinnerDescController.text.trim()
                        : null,
                  );

                  await _dbService.createMessMenu(menu);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Menu added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMenuDialog(MessMenu menu) {
    final breakfastController = TextEditingController(text: menu.breakfast);
    final lunchController = TextEditingController(text: menu.lunch);
    final dinnerController = TextEditingController(text: menu.dinner);
    final breakfastDescController = TextEditingController(text: menu.breakfastDescription ?? '');
    final lunchDescController = TextEditingController(text: menu.lunchDescription ?? '');
    final dinnerDescController = TextEditingController(text: menu.dinnerDescription ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Menu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Date: ${_formatDate(menu.date)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: breakfastController,
                label: 'Breakfast',
                prefixIcon: Icons.free_breakfast,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: breakfastDescController,
                label: 'Breakfast Description (Optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: lunchController,
                label: 'Lunch',
                prefixIcon: Icons.lunch_dining,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: lunchDescController,
                label: 'Lunch Description (Optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: dinnerController,
                label: 'Dinner',
                prefixIcon: Icons.dinner_dining,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: dinnerDescController,
                label: 'Dinner Description (Optional)',
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (breakfastController.text.isEmpty ||
                  lunchController.text.isEmpty ||
                  dinnerController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all meal fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await _dbService.updateMessMenu(menu.menuId, {
                  'breakfast': breakfastController.text.trim(),
                  'lunch': lunchController.text.trim(),
                  'dinner': dinnerController.text.trim(),
                  'breakfastDescription': breakfastDescController.text.trim().isNotEmpty
                      ? breakfastDescController.text.trim()
                      : null,
                  'lunchDescription': lunchDescController.text.trim().isNotEmpty
                      ? lunchDescController.text.trim()
                      : null,
                  'dinnerDescription': dinnerDescController.text.trim().isNotEmpty
                      ? dinnerDescController.text.trim()
                      : null,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menu updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
