import 'dart:io';

import 'package:flutter/services.dart';

/// Platform channel wrapper for iOS significant location change monitoring.
/// No-ops on Android.
class SignificantLocationService {
  SignificantLocationService._();

  static const _channel = MethodChannel('com.totms.heather/location');

  /// Starts significant location change monitoring on iOS.
  /// Requires "Always" location permission to be effective.
  static Future<void> startMonitoring() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('startMonitoring');
    } on PlatformException catch (_) {
      // Silently ignore — monitoring just won't start
    }
  }

  /// Stops significant location change monitoring on iOS.
  static Future<void> stopMonitoring() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stopMonitoring');
    } on PlatformException catch (_) {
      // Silently ignore
    }
  }

  /// Returns true if "Always" location permission is granted on iOS.
  /// Always returns false on Android.
  static Future<bool> hasAlwaysPermission() async {
    if (!Platform.isIOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('hasAlwaysPermission');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
