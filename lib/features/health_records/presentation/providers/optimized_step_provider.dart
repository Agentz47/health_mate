// optimized_step_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/repositories/health_repository_impl.dart';

// Tunables
const int UI_UPDATE_DEBOUNCE_MS = 500;
const int PERSIST_INTERVAL_SECONDS = 30;
const int PERSIST_STEP_DELTA = 10;

// SharedPref keys (use same names in provider)
const String _kBaselineKey = 'steps_baseline';
const String _kLastSensorKey = 'steps_last_sensor';
const String _kLastSavedStepsKey = 'steps_last_saved';
const String _kLastSaveTsKey = 'steps_last_save_ts';
const String _kLastDateKey = 'steps_last_date';

class OptimizedStepProvider extends ChangeNotifier {
  final HealthRepositoryImpl _healthRepository;
  final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');
  
  StreamSubscription<StepCount>? _stepSub;
  int _liveSteps = 0;
  int _baseline = 0;
  int _lastSensor = 0;
  int _lastSavedSteps = 0;
  DateTime _lastSaveTime = DateTime.fromMillisecondsSinceEpoch(0);
  String _lastDate = '';
  Timer? _uiDebounceTimer;
  Timer? _persistTimer;
  bool _listening = false;
  bool _permissionGranted = false;

  bool get isListening => _listening;
  int get liveSteps => _liveSteps;
  bool get hasPermission => _permissionGranted;

  OptimizedStepProvider(this._healthRepository) {
    _init();
  }

  Future<void> _init() async {
    await _loadPersistentState();
    await _requestPermissions();
    _checkDayBoundary(); // Check if day changed since last run
    _startListening();
    _startPersistTimer();
  }

  Future<void> _loadPersistentState() async {
    final prefs = await SharedPreferences.getInstance();
    _baseline = prefs.getInt(_kBaselineKey) ?? 0;
    _lastSensor = prefs.getInt(_kLastSensorKey) ?? 0;
    _lastSavedSteps = prefs.getInt(_kLastSavedStepsKey) ?? 0;
    _lastSaveTime = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(_kLastSaveTsKey) ?? 0,
    );
    _lastDate = prefs.getString(_kLastDateKey) ?? '';
    _liveSteps = _lastSavedSteps; // Resume from last saved value
  }

  Future<void> _savePersistentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBaselineKey, _baseline);
    await prefs.setInt(_kLastSensorKey, _lastSensor);
    await prefs.setInt(_kLastSavedStepsKey, _lastSavedSteps);
    await prefs.setInt(_kLastSaveTsKey, _lastSaveTime.millisecondsSinceEpoch);
    await prefs.setString(_kLastDateKey, _lastDate);
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.activityRecognition.status;
    debugPrint('Activity Recognition permission status: $status');
    
    if (status.isDenied) {
      debugPrint('Requesting Activity Recognition permission...');
      final result = await Permission.activityRecognition.request();
      _permissionGranted = result.isGranted;
      debugPrint('Permission request result: $result');
    } else {
      _permissionGranted = status.isGranted;
    }
    
    debugPrint('Permission granted: $_permissionGranted');
    notifyListeners();
  }
  
  /// Manually request permission again (for testing)
  Future<void> requestPermission() async {
    await _requestPermissions();
    if (_permissionGranted && !_listening) {
      _startListening();
    }
  }

  void _checkDayBoundary() {
    final today = _dateFmt.format(DateTime.now());
    if (_lastDate.isNotEmpty && _lastDate != today) {
      // Day changed - finalize previous day and reset for new day
      debugPrint('Day boundary detected: $_lastDate -> $today. Resetting baseline.');
      _baseline = _lastSensor; // Reset baseline to last known sensor value
      _liveSteps = 0;
      _lastSavedSteps = 0;
    }
    _lastDate = today;
  }

  void _startListening() {
    if (!_permissionGranted) {
      debugPrint('Step counter: Permission not granted, cannot start listening');
      return;
    }

    try {
      debugPrint('Step counter: Starting pedometer stream...');
      _stepSub = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onError,
        cancelOnError: false,
      );
      _listening = true;
      debugPrint('Step counter: Pedometer stream started successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Step counter: Error starting pedometer: $e');
      _listening = false;
      notifyListeners();
    }
  }

  void _onError(error) {
    debugPrint('Pedometer error: $error');
    _listening = false;
    notifyListeners();
  }

  void _onStepCount(StepCount event) async {
    final int sensorValue = event.steps;
    final now = DateTime.now();
    final today = _dateFmt.format(now);

    debugPrint('Step counter: Received step count: $sensorValue at ${event.timeStamp}');

    // Check for day boundary
    if (_lastDate != today) {
      debugPrint('Step counter: Day boundary detected, persisting previous day');
      await _persistStepsNow(); // Save previous day's final count
      _lastDate = today;
      _baseline = sensorValue; // Reset baseline for new day
      _liveSteps = 0;
      _lastSavedSteps = 0;
      await _savePersistentState();
      _scheduleUiNotify();
      return;
    }

    // Handle sensor reset (device reboot or sensor rollover)
    if (sensorValue < _lastSensor) {
      debugPrint('Step counter: Sensor reset detected: $sensorValue < $_lastSensor');
      _baseline = sensorValue;
      _liveSteps = 0;
      _lastSavedSteps = 0;
      _lastSensor = sensorValue;
      await _savePersistentState();
      _scheduleUiNotify();
      return;
    }

    // Initialize baseline on first reading
    if (_baseline == 0 && _lastSensor == 0) {
      debugPrint('Step counter: Initializing baseline to $sensorValue');
      _baseline = sensorValue;
    }

    _lastSensor = sensorValue;

    // Compute live steps
    final computedSteps = sensorValue - _baseline;
    _liveSteps = computedSteps < 0 ? 0 : computedSteps; // Clamp to non-negative

    debugPrint('Step counter: Live steps = $_liveSteps (sensor: $sensorValue, baseline: $_baseline)');

    // Debounce UI updates (max 2/sec)
    _scheduleUiNotify();

    // Decide whether to persist
    final stepDelta = (_liveSteps - _lastSavedSteps).abs();
    final timeSinceLastSave = now.difference(_lastSaveTime).inSeconds;

    if (stepDelta >= PERSIST_STEP_DELTA || timeSinceLastSave >= PERSIST_INTERVAL_SECONDS) {
      debugPrint('Step counter: Persisting (delta: $stepDelta, time: ${timeSinceLastSave}s)');
      await _persistStepsNow();
    }
  }

  void _scheduleUiNotify() {
    if (_uiDebounceTimer?.isActive ?? false) return;
    _uiDebounceTimer = Timer(
      Duration(milliseconds: UI_UPDATE_DEBOUNCE_MS),
      () {
        notifyListeners();
      },
    );
  }

  void _startPersistTimer() {
    _persistTimer ??= Timer.periodic(
      Duration(seconds: PERSIST_INTERVAL_SECONDS),
      (_) => _persistStepsNow(),
    );
  }

  Future<void> _persistStepsNow() async {
    if (_liveSteps == _lastSavedSteps) return; // No change

    final today = _dateFmt.format(DateTime.now());
    
    try {
      await _healthRepository.upsertTodaySteps(
        dateString: today,
        steps: _liveSteps,
      );
      
      _lastSavedSteps = _liveSteps;
      _lastSaveTime = DateTime.now();
      await _savePersistentState();
      
      debugPrint('Persisted steps: $_liveSteps for $today');
    } catch (e) {
      debugPrint('Error persisting steps: $e');
    }
  }

  /// Call this when app goes to background/pause
  Future<void> persistOnPause() async {
    await _persistStepsNow();
  }

  /// Force reset baseline (utility for testing)
  Future<void> forceResetBaseline() async {
    _baseline = _lastSensor;
    _liveSteps = 0;
    _lastSavedSteps = 0;
    await _savePersistentState();
    notifyListeners();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _uiDebounceTimer?.cancel();
    _persistTimer?.cancel();
    persistOnPause(); // Save on dispose
    super.dispose();
  }
}
