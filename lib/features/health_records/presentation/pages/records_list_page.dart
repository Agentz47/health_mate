import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';
import '../../domain/entities/health_record.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import 'add_edit_record_page.dart';

class RecordsListPage extends StatefulWidget {
  const RecordsListPage({super.key});

  @override
  State<RecordsListPage> createState() => _RecordsListPageState();
}

class _RecordsListPageState extends State<RecordsListPage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by Date',
            onPressed: _selectDate,
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Filter',
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
            ),
        ],
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter records by selected date if any
          final records = _selectedDate != null
              ? provider.filterByDate(_selectedDate!)
              : provider.records;

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedDate != null
                        ? 'No records for ${DateFormatter.formatForDisplay(_selectedDate!)}'
                        : 'No health records yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add your first record',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedDate != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Showing records for ${DateFormatter.formatForDisplay(_selectedDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return _buildRecordCard(context, record, provider);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditRecordPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    HealthRecord record,
    HealthRecordProvider provider,
  ) {
    final isToday = DateFormatter.isToday(record.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditRecordPage(record: record),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isToday ? AppTheme.primaryColor : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatForDisplay(record.date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? AppTheme.primaryColor : null,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditRecordPage(record: record),
                          ),
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(context, record, provider);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    Icons.directions_walk,
                    '${record.steps}',
                    'Steps',
                    AppTheme.stepsColor,
                  ),
                  _buildStatChip(
                    Icons.local_fire_department,
                    '${record.calories}',
                    'kcal',
                    AppTheme.caloriesColor,
                  ),
                  _buildStatChip(
                    Icons.water_drop,
                    '${record.water}',
                    'ml',
                    AppTheme.waterColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormatter.stripTime(picked);
      });
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HealthRecord record,
    HealthRecordProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete the record for ${DateFormatter.formatForDisplay(record.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && record.id != null) {
      final success = await provider.deleteRecord(record.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Record deleted successfully'
                  : 'Failed to delete record',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
