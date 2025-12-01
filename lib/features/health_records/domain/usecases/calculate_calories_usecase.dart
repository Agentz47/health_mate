// UseCase for calculating calories burned from steps

// Supports two formulas:
// 1. Personalized: steps * (weightKg * 0.0005) - when weight is provided
// 2. Default: steps * 0.05 - when weight is not available
class CalculateCaloriesUseCase {
  // Calculate calories burned from steps
 
  // steps - Number of steps taken
  // weightKg - User's weight in kilograms (optional)
   
  // Returns estimated calories burned as a double
  double call({required int steps, double? weightKg}) {
    if (weightKg != null && weightKg > 0) {
      // Personalized formula based on user weight
      // Assumption: heavier person burns more calories per step
      return steps * (weightKg * 0.0005);
    }
    
    // Default fallback formula (assumes average weight ~70kg)
    return steps * 0.05;
  }
}
