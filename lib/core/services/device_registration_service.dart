import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsLocationsKey = 'device_reg_locations';
const _prefsAlertsEnabledKey = 'device_reg_alerts_enabled';

class DeviceRegistrationService {
  static final DeviceRegistrationService _instance =
      DeviceRegistrationService._();
  factory DeviceRegistrationService() => _instance;
  DeviceRegistrationService._();

  late final _messaging = FirebaseMessaging.instance;
  late final _firestore = FirebaseFirestore.instance;

  String? _currentToken;
  StreamSubscription<String>? _tokenRefreshSub;
  List<Map<String, dynamic>> _lastLocations = [];
  bool _lastAlertsEnabled = true;

  Future<void> _restoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getString(_prefsLocationsKey);
    if (locationsJson != null) {
      _lastLocations =
          (jsonDecode(locationsJson) as List<dynamic>).cast<Map<String, dynamic>>();
    }
    _lastAlertsEnabled = prefs.getBool(_prefsAlertsEnabledKey) ?? true;
  }

  Future<void> init() async {
    // Restore persisted locations so _handleNewToken writes real data
    // to Firestore immediately on cold start.
    await _restoreFromPrefs();

    // Listen for token refresh before fetching — so we don't miss a refresh
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_handleNewToken);

    // Await the initial token so _currentToken is set before callers proceed.
    // On iOS without permission this returns null immediately; onTokenRefresh
    // fires after permission is granted in onboarding.
    final token = await _messaging.getToken();
    if (token != null) {
      _handleNewToken(token);
    }
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

    // Write device doc so it exists even before locations are loaded.
    // Cloud Function filters by alertsEnabled and the locations loop is a
    // no-op on empty arrays, so this is safe.
    _writeDeviceDoc(newToken, _lastLocations, _lastAlertsEnabled);
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

    // Persist so next cold start has real locations immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLocationsKey, jsonEncode(locations));
    await prefs.setBool(_prefsAlertsEnabledKey, alertsEnabled);

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
