import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class DeviceRegistrationService {
  static final DeviceRegistrationService _instance =
      DeviceRegistrationService._();
  factory DeviceRegistrationService() => _instance;
  DeviceRegistrationService._();

  final _messaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  List<Map<String, dynamic>> _lastLocations = [];
  bool _lastAlertsEnabled = true;

  Future<void> init() async {
    // Get initial token (non-blocking — on iOS this may wait for permission)
    _messaging.getToken().then((token) {
      if (token != null) {
        _handleNewToken(token);
      }
    });

    // Listen for token refresh
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_handleNewToken);
  }

  void _handleNewToken(String newToken) {
    final oldToken = _currentToken;
    _currentToken = newToken;

    if (kDebugMode) {
      print('FCM token: $newToken');
    }

    // If we had a previous token, migrate the device doc
    if (oldToken != null && oldToken != newToken) {
      _migrateToken(oldToken, newToken);
    }

    // Re-register with current locations if we have them
    if (_lastLocations.isNotEmpty) {
      _writeDeviceDoc(newToken, _lastLocations, _lastAlertsEnabled);
    }
  }

  Future<void> _migrateToken(String oldToken, String newToken) async {
    try {
      final oldDoc = _firestore.collection('devices').doc(oldToken);
      final snapshot = await oldDoc.get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        await _firestore.collection('devices').doc(newToken).set(data);
        await oldDoc.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token migration failed: $e');
      }
    }
  }

  /// Register the device's monitored locations in Firestore.
  /// Called whenever GPS location, saved locations, or alert settings change.
  Future<void> registerLocations({
    required List<Map<String, dynamic>> locations,
    required bool alertsEnabled,
  }) async {
    _lastLocations = locations;
    _lastAlertsEnabled = alertsEnabled;

    final token = _currentToken;
    if (token == null) return;

    await _writeDeviceDoc(token, locations, alertsEnabled);
  }

  Future<void> _writeDeviceDoc(
    String token,
    List<Map<String, dynamic>> locations,
    bool alertsEnabled,
  ) async {
    try {
      await _firestore.collection('devices').doc(token).set({
        'locations': locations
            .map((loc) => {
                  'latitude': loc['latitude'] as double,
                  'longitude': loc['longitude'] as double,
                  'name': loc['name'] as String? ?? '',
                })
            .toList(),
        'alertsEnabled': alertsEnabled,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Device registration failed: $e');
      }
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}
