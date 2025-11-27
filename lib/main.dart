import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/health_records/data/datasources/local/database_helper.dart';
import 'features/health_records/data/repositories/health_repository_impl.dart';
import 'features/health_records/presentation/providers/health_record_provider.dart';
import 'features/health_records/presentation/providers/optimized_step_provider.dart';
import 'features/health_records/domain/usecases/calculate_calories_usecase.dart';
import 'features/user_profile/data/user_profile_local.dart';
import 'features/user_profile/presentation/providers/user_profile_provider.dart';
import 'features/user_profile/presentation/pages/welcome_page.dart';
import 'features/user_profile/presentation/pages/greeting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HealthRecordProvider(
            HealthRepositoryImpl(DatabaseHelper.instance),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => OptimizedStepProvider(
            HealthRepositoryImpl(DatabaseHelper.instance),
            CalculateCaloriesUseCase(),
            UserProfileLocal(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProfileProvider(
            UserProfileLocal(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

/// Splash screen to check if user profile exists
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final userProfileLocal = UserProfileLocal();
    final hasProfile = await userProfileLocal.hasProfile();

    if (mounted) {
      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // If profile exists, always show GreetingPage (not Dashboard)
          // User must press "Be Active" to go to Dashboard
          builder: (context) => hasProfile 
              ? const GreetingPage() 
              : const WelcomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'HealthMate',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
