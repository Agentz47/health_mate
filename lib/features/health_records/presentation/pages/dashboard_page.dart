import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_record_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import 'records_list_page.dart';
import 'add_edit_record_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load records when the page is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthRecordProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'View All Records',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordsListPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRecords(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadRecords(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Date Header
                  Text(
                    DateFormatter.formatForDisplay(DateTime.now()),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Today's Summary",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  _buildSummaryCard(
                    context,
                    icon: Icons.directions_walk,
                    title: 'Steps',
                    value: provider.todaySteps.toString(),
                    color: AppTheme.stepsColor,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    icon: Icons.local_fire_department,
                    title: 'Calories',
                    value: '${provider.todayCalories} kcal',
                    color: AppTheme.caloriesColor,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    context,
                    icon: Icons.water_drop,
                    title: 'Water',
                    value: '${provider.todayWater} ml',
                    color: AppTheme.waterColor,
                  ),
                  const SizedBox(height: 32),

                  // Quick Stats
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatRow(
                            'Total Records',
                            provider.records.length.toString(),
                          ),
                          const Divider(),
                          _buildStatRow(
                            'This Week',
                            _getWeekRecordsCount(provider).toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditRecordPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _getWeekRecordsCount(HealthRecordProvider provider) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return provider.getRecordsBetween(weekAgo, now).length;
  }
}
