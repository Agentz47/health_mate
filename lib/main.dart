import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/health_records/data/datasources/local/database_helper.dart';
import 'features/health_records/data/repositories/health_repository_impl.dart';
import 'features/health_records/presentation/providers/health_record_provider.dart';
import 'features/health_records/presentation/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HealthRecordProvider(
        HealthRepositoryImpl(DatabaseHelper.instance),
      ),
      child: MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardPage(),
      ),
    );
  }
}
