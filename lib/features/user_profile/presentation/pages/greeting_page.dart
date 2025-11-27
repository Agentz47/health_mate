import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../providers/user_profile_provider.dart';
import 'welcome_page.dart';
import '../../../health_records/presentation/pages/dashboard_page.dart';

class GreetingPage extends StatelessWidget {
  const GreetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientScaffold(
      body: SafeArea(
        child: Consumer<UserProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = provider.profile;
            final name = profile?.name ?? 'there';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Header with Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppGradients.getPrimaryButton(isDark),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.getTextSecondary(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Profile Details Card
                  if (profile?.hasAnyData ?? false) ...[
                    GradientCard(
                      gradient: AppGradients.getCard(isDark),
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: AppColors.getPrimary(isDark),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Profile',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProfileTiles(context, profile, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Motivational Quote
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.darkSurface 
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark 
                            ? AppColors.darkPrimary 
                            : Colors.blue[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: isDark 
                              ? AppColors.darkPrimary 
                              : Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ready to track your health journey today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextPrimary(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Be Active Button (Primary) with Gradient
                  GradientButton(
                    onPressed: () => _navigateToDashboard(context),
                    gradient: AppGradients.getPrimaryButton(isDark),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_run, size: 24, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Be Active',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Edit Button
                  OutlinedButton(
                    onPressed: () => _navigateToEdit(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clear Profile Button
                  TextButton.icon(
                    onPressed: () => _showClearProfileDialog(context, provider),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Clear Profile'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer Hint
                  Text(
                    'You can update these details anytime',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileTiles(BuildContext context, profile, bool isDark) {
    final tiles = <Widget>[];

    if (profile.weightKg != null) {
      tiles.add(_buildProfileTile(
        context,
        icon: Icons.monitor_weight,
        label: 'Weight',
        value: '${profile.weightKg} kg',
        color: AppColors.getWaterColor(isDark),
        isDark: isDark,
      ));
    }

    if (profile.heightCm != null) {
      tiles.add(_buildProfileTile(
        context,
        icon: Icons.height,
        label: 'Height',
        value: '${profile.heightCm} cm',
        color: AppColors.getStepsColor(isDark),
        isDark: isDark,
      ));
    }

    if (profile.age != null) {
      tiles.add(_buildProfileTile(
        context,
        icon: Icons.cake,
        label: 'Age',
        value: '${profile.age} years',
        color: AppColors.getCaloriesColor(isDark),
        isDark: isDark,
      ));
    }

    if (tiles.isEmpty) {
      return const Text('No profile details saved yet');
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles,
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.getTextSecondary(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WelcomePage(isEditMode: true),
      ),
    ).then((_) {
      // Refresh profile when returning from edit
      context.read<UserProfileProvider>().refresh();
    });
  }

  void _showClearProfileDialog(
    BuildContext context,
    UserProfileProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear profile?'),
        content: const Text(
          'This will remove your saved details. You can re-enter them later. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await provider.clearProfile();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const WelcomePage(),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
