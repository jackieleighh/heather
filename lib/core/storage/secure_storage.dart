import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  static const _geminiKeyKey = 'gemini_api_key';

  Future<void> saveGeminiKey(String key) async {
    await _storage.write(key: _geminiKeyKey, value: key);
  }

  Future<String?> getGeminiKey() async {
    return _storage.read(key: _geminiKeyKey);
  }

  Future<void> deleteGeminiKey() async {
    await _storage.delete(key: _geminiKeyKey);
  }
}
