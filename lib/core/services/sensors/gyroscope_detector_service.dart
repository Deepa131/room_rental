import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final gyroscopeDetectorServiceProvider = Provider<GyroscopeDetectorService>((ref) {
  return GyroscopeDetectorService();
});

class GyroscopeDetectorService {
  static const double _tiltThreshold = 1.5; 
  static const Duration _debounceWindow = Duration(milliseconds: 800); // Prevent rapid triggers

  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  VoidCallback? _onLeftTilt;
  VoidCallback? _onRightTilt;
  DateTime _lastTiltTime = DateTime.now();

  /// Start listening for gyroscope (tilt) gestures
  void startListening({
    required VoidCallback onLeftTilt,
    required VoidCallback onRightTilt,
  }) {
    _onLeftTilt = onLeftTilt;
    _onRightTilt = onRightTilt;

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      final now = DateTime.now();

      // Check if enough time has passed since last tilt
      if (now.difference(_lastTiltTime) < _debounceWindow) {
        return;
      }

      // Detect left tilt
      if (event.z < -_tiltThreshold) {
        _lastTiltTime = now;
        _onLeftTilt?.call();
        debugPrint('🔄 Left Tilt Detected! Z-axis: ${event.z}');
      }

      // Detect right tilt 
      if (event.z > _tiltThreshold) {
        _lastTiltTime = now;
        _onRightTilt?.call();
        debugPrint('🔄 Right Tilt Detected! Z-axis: ${event.z}');
      }
    });
  }

  // Stop listening for gyroscope gestures
  void stopListening() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
    _onLeftTilt = null;
    _onRightTilt = null;
  }

  // Dispose of the service
  void dispose() {
    stopListening();
  }
}

// Widget wrapper that enables gyroscope (tilt) detection for its child
class GyroscopeDetectorWidget extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onLeftTilt;
  final VoidCallback onRightTilt;
  final bool enabled;

  const GyroscopeDetectorWidget({
    super.key,
    required this.child,
    required this.onLeftTilt,
    required this.onRightTilt,
    this.enabled = true,
  });

  @override
  ConsumerState<GyroscopeDetectorWidget> createState() =>
      _GyroscopeDetectorWidgetState();
}

class _GyroscopeDetectorWidgetState extends ConsumerState<GyroscopeDetectorWidget> {
  late GyroscopeDetectorService _gyroscopeService;

  @override
  void initState() {
    super.initState();
    _gyroscopeService = ref.read(gyroscopeDetectorServiceProvider);
    if (widget.enabled) {
      _startListening();
    }
  }

  void _startListening() {
    _gyroscopeService.startListening(
      onLeftTilt: widget.onLeftTilt,
      onRightTilt: widget.onRightTilt,
    );
  }

  @override
  void didUpdateWidget(GyroscopeDetectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startListening();
      } else {
        _gyroscopeService.stopListening();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enabled) {
      _gyroscopeService.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
