import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/user_profile_local.dart';
import '../../../health_records/presentation/pages/dashboard_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _userProfileLocal = UserProfileLocal();

  // Controllers
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Load existing profile data if available
  Future<void> _loadExistingProfile() async {
    final profile = await _userProfileLocal.loadProfile();
    
    if (profile['name'] != null) {
      _nameController.text = profile['name'];
    }
    if (profile['weightKg'] != null) {
      _weightController.text = profile['weightKg'].toString();
    }
    if (profile['heightCm'] != null) {
      _heightController.text = profile['heightCm'].toString();
    }
    if (profile['age'] != null) {
      _ageController.text = profile['age'].toString();
    }
  }

  /// Save profile and navigate to dashboard
  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse input values
      final name = _nameController.text.trim().isEmpty 
          ? null 
          : _nameController.text.trim();
      
      final weightKg = _weightController.text.trim().isEmpty
          ? null
          : double.tryParse(_weightController.text.trim());
      
      final heightCm = _heightController.text.trim().isEmpty
          ? null
          : int.tryParse(_heightController.text.trim());
      
      final age = _ageController.text.trim().isEmpty
          ? null
          : int.tryParse(_ageController.text.trim());

      // Save profile
      await _userProfileLocal.saveProfile(
        name: name,
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
      );

      if (mounted) {
        _navigateToDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Skip onboarding and go to dashboard
  void _skipAndContinue() {
    _navigateToDashboard();
  }

  /// Navigate to dashboard
  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Welcome Header
                const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Welcome to HealthMate',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Let\'s personalize your health journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name (Optional)',
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Weight Field (Most Important)
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg) - Recommended',
                    hintText: 'e.g., 70',
                    prefixIcon: const Icon(Icons.monitor_weight),
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Used for personalized calorie calculations',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Optional field
                    }
                    final weight = double.tryParse(value.trim());
                    if (weight == null) {
                      return 'Please enter a valid number';
                    }
                    if (weight < 20 || weight > 400) {
                      return 'Weight must be between 20-400 kg';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Height Field
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: 'Height (cm) - Optional',
                    hintText: 'e.g., 170',
                    prefixIcon: const Icon(Icons.height),
                    suffixText: 'cm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Optional field
                    }
                    final height = int.tryParse(value.trim());
                    if (height == null) {
                      return 'Please enter a valid number';
                    }
                    if (height < 50 || height > 300) {
                      return 'Height must be between 50-300 cm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Age Field
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age (years) - Optional',
                    hintText: 'e.g., 25',
                    prefixIcon: const Icon(Icons.cake),
                    suffixText: 'years',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // Optional field
                    }
                    final age = int.tryParse(value.trim());
                    if (age == null) {
                      return 'Please enter a valid number';
                    }
                    if (age < 5 || age > 120) {
                      return 'Age must be between 5-120 years';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All fields are optional. Providing your weight helps us give you more accurate calorie estimates.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save & Be Active',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),

                // Skip Button
                OutlinedButton(
                  onPressed: _isLoading ? null : _skipAndContinue,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Be Active (Skip)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
