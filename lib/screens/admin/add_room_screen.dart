import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_text_field.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();
  final _blockController = TextEditingController();

  RoomType _selectedType = RoomType.double;
  int _capacity = 2;
  bool _isLoading = false;
  final String _hostelId = 'H1'; // Should be fetched from settings

  @override
  void dispose() {
    _roomNumberController.dispose();
    _floorController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final room = Room(
        roomId: '', // Will be auto-generated
        hostelId: _hostelId,
        roomNumber: _roomNumberController.text.trim(),
        type: _selectedType,
        capacity: _capacity,
        floor: _floorController.text.trim(),
        block: _blockController.text.trim(),
      );

      await _dbService.createRoom(room);

      if (mounted) {
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Room'),
        backgroundColor: AppColors.wardenColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            CustomTextField(
              controller: _roomNumberController,
              label: 'Room Number',
              prefixIcon: Icons.meeting_room,
              validator: (value) =>
                  Validators.validateRequired(value, 'Room number'),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            DropdownButtonFormField<RoomType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Room Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              items: RoomType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    // Auto-set capacity based on type
                    switch (value) {
                      case RoomType.single:
                        _capacity = 1;
                        break;
                      case RoomType.double:
                        _capacity = 2;
                        break;
                      case RoomType.triple:
                        _capacity = 3;
                        break;
                      case RoomType.quad:
                        _capacity = 4;
                        break;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextFormField(
              initialValue: _capacity.toString(),
              decoration: InputDecoration(
                labelText: 'Capacity',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  Validators.validatePositiveNumber(value, 'Capacity'),
              onChanged: (value) {
                final capacity = int.tryParse(value);
                if (capacity != null && capacity > 0) {
                  _capacity = capacity;
                }
              },
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _floorController,
              label: 'Floor (Optional)',
              prefixIcon: Icons.layers,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            CustomTextField(
              controller: _blockController,
              label: 'Block (Optional)',
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.wardenColor,
                ),
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
                    : const Text('Add Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
