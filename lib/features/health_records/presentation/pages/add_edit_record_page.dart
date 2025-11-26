import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';
import '../../domain/entities/health_record.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/constants/app_constants.dart';

class AddEditRecordPage extends StatefulWidget {
  final HealthRecord? record;

  const AddEditRecordPage({super.key, this.record});

  @override
  State<AddEditRecordPage> createState() => _AddEditRecordPageState();
}

class _AddEditRecordPageState extends State<AddEditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _stepsController;
  late TextEditingController _caloriesController;
  late TextEditingController _waterController;

  bool get isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.record?.date ?? DateTime.now();
    _stepsController = TextEditingController(
      text: widget.record?.steps.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: widget.record?.calories.toString() ?? '',
    );
    _waterController = TextEditingController(
      text: widget.record?.water.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Record' : 'Add Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Picker
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(DateFormatter.formatForDisplay(_selectedDate)),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 24),

              // Steps Input
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steps Walked',
                  hintText: 'Enter number of steps',
                  prefixIcon: Icon(Icons.directions_walk),
                  suffixText: 'steps',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  final steps = int.tryParse(value);
                  if (steps == null) {
                    return 'Please enter a valid number';
                  }
                  if (steps < AppConstants.minValue) {
                    return 'Steps must be at least ${AppConstants.minValue}';
                  }
                  if (steps > AppConstants.maxSteps) {
                    return 'Steps cannot exceed ${AppConstants.maxSteps}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories Input
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned',
                  hintText: 'Enter calories burned',
                  prefixIcon: Icon(Icons.local_fire_department),
                  suffixText: 'kcal',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  final calories = int.tryParse(value);
                  if (calories == null) {
                    return 'Please enter a valid number';
                  }
                  if (calories < AppConstants.minValue) {
                    return 'Calories must be at least ${AppConstants.minValue}';
                  }
                  if (calories > AppConstants.maxCalories) {
                    return 'Calories cannot exceed ${AppConstants.maxCalories}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Water Input
              TextFormField(
                controller: _waterController,
                decoration: const InputDecoration(
                  labelText: 'Water Intake',
                  hintText: 'Enter water intake',
                  prefixIcon: Icon(Icons.water_drop),
                  suffixText: 'ml',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water intake';
                  }
                  final water = int.tryParse(value);
                  if (water == null) {
                    return 'Please enter a valid number';
                  }
                  if (water < AppConstants.minValue) {
                    return 'Water must be at least ${AppConstants.minValue}';
                  }
                  if (water > AppConstants.maxWater) {
                    return 'Water cannot exceed ${AppConstants.maxWater}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  isEditing ? 'Update Record' : 'Save Record',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateFormatter.stripTime(picked);
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<HealthRecordProvider>();

    final record = HealthRecord(
      id: widget.record?.id,
      date: _selectedDate,
      steps: int.parse(_stepsController.text),
      calories: int.parse(_caloriesController.text),
      water: int.parse(_waterController.text),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateRecord(record);
    } else {
      success = await provider.addRecord(record);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Record updated successfully'
                  : 'Record added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to save record',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
