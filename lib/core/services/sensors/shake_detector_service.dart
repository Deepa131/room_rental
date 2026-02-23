import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final shakeDetectorServiceProvider = Provider<ShakeDetectorService>((ref) {
  return ShakeDetectorService();
});

class ShakeDetectorService {
  static const double _shakeThreshold = 15.0;
  static const int _shakeCount = 3; 
  static const Duration _shakeWindow = Duration(seconds: 3); 
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final List<DateTime> _shakeTimestamps = [];
  VoidCallback? _onShakeDetected;
  
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastShakeTime = DateTime.now();

  void startListening({required VoidCallback onShakeDetected}) {
    _onShakeDetected = onShakeDetected;
    
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      final now = DateTime.now();
      
      final deltaX = (event.x - _lastX).abs();
      final deltaY = (event.y - _lastY).abs();
      final deltaZ = (event.z - _lastZ).abs();
      
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;
      
      final totalDelta = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
      
      if (totalDelta > _shakeThreshold) {
        if (now.difference(_lastShakeTime).inMilliseconds > 500) {
          _lastShakeTime = now;
          _registerShake();
        }
      }
    });
  }

  void _registerShake() {
    final now = DateTime.now();
    
    _shakeTimestamps.removeWhere((timestamp) {
      return now.difference(timestamp) > _shakeWindow;
    });
    _shakeTimestamps.add(now);
    
    if (_shakeTimestamps.length >= _shakeCount) {
      _onShakeDetected?.call();
      _shakeTimestamps.clear(); 
    }
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _shakeTimestamps.clear();
    _onShakeDetected = null;
  }

  void dispose() {
    stopListening();
  }
}

class ShakeDetectorWidget extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onShakeDetected;
  final bool enabled;

  const ShakeDetectorWidget({
    super.key,
    required this.child,
    required this.onShakeDetected,
    this.enabled = true,
  });

  @override
  ConsumerState<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends ConsumerState<ShakeDetectorWidget> {
  late ShakeDetectorService _shakeService;

  @override
  void initState() {
    super.initState();
    _shakeService = ref.read(shakeDetectorServiceProvider);
    if (widget.enabled) {
      _startListening();
    }
  }

  void _startListening() {
    _shakeService.startListening(onShakeDetected: widget.onShakeDetected);
  }

  @override
  void didUpdateWidget(ShakeDetectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _shakeService.stopListening();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      _shakeService.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
