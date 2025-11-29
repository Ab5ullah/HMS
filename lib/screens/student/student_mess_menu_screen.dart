import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mess.dart';
import '../../providers/mess_provider.dart';
import '../../utils/constants.dart';

class StudentMessMenuScreen extends StatefulWidget {
  const StudentMessMenuScreen({super.key});

  @override
  State<StudentMessMenuScreen> createState() => _StudentMessMenuScreenState();
}

class _StudentMessMenuScreenState extends State<StudentMessMenuScreen> {
  @override
  void initState() {
    super.initState();
    _loadWeekMenu();
  }

  Future<void> _loadWeekMenu() async {
    await context.read<MessProvider>().getWeekMenu();
  }

  @override
  Widget build(BuildContext context) {
    final messProvider = context.watch<MessProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Menu'),
        backgroundColor: AppColors.studentColor,
      ),
      body: messProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : messProvider.menus.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadWeekMenu,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    children: [
                      _buildTodayMenu(messProvider),
                      const SizedBox(height: AppSizes.paddingMedium),
                      _buildWeeklyMenu(messProvider),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No menu available',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMenu(MessProvider provider) {
    final today = DateTime.now();
    final todayMenu = provider.menus.where((menu) {
      return menu.date.year == today.year &&
          menu.date.month == today.month &&
          menu.date.day == today.day;
    }).toList();

    if (todayMenu.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              const Text(
                "Today's Menu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'No menu published for today',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.studentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...todayMenu.map((menu) => _buildMealCard(menu, isToday: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMenu(MessProvider provider) {
    final menus = provider.menus.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Group by date
    final Map<String, List<MessMenu>> menusByDate = {};
    for (var menu in menus) {
      final dateKey = _formatDate(menu.date);
      if (!menusByDate.containsKey(dateKey)) {
        menusByDate[dateKey] = [];
      }
      menusByDate[dateKey]!.add(menu);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Menu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        ...menusByDate.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
            child: ExpansionTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${entry.value.length} meals',
                style: const TextStyle(fontSize: 12),
              ),
              children: entry.value.map((menu) => _buildMealCard(menu)).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMealCard(MessMenu menu, {bool isToday = false}) {
    IconData icon;
    Color color;
    
    switch (menu.mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = Colors.green;
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = Colors.blue;
        break;
      case 'snacks':
        icon = Icons.cookie;
        color = Colors.brown;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        menu.mealType.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          ...menu.items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              )),
        ],
      ),
      isThreeLine: true,
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}/${date.year}';
  }
}
