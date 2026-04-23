import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class GlpiSessionData {
  const GlpiSessionData({
    required this.baseUrl,
    required this.username,
  });

  final String baseUrl;
  final String username;
}

class GlpiAuthStorage {
  GlpiAuthStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kBaseUrl = 'glpi_base_url';
  static const _kUsername = 'glpi_username';
  static const _kAccessToken = 'glpi_access_token';

  Future<void> saveSession(GlpiSessionData session) async {
    try {
      await _storage.write(key: _kBaseUrl, value: session.baseUrl);
      await _storage.write(key: _kUsername, value: session.username);
      // Do not persist bearer tokens; require fresh credential verification.
      await _storage.delete(key: _kAccessToken);
    } on MissingPluginException {
      // Plugin unavailable in current runtime.
    } on PlatformException {
      // Secure storage unavailable on current platform/runtime.
    }
  }

  Future<GlpiSessionData?> readSession() async {
    try {
      final baseUrl = await _storage.read(key: _kBaseUrl);
      final username = await _storage.read(key: _kUsername);
      if (baseUrl == null || username == null || username.trim().isEmpty) {
        return null;
      }

      return GlpiSessionData(
        baseUrl: baseUrl,
        username: username,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> clearSession() async {
    try {
      // Delete known auth keys explicitly so logout is reliable across platforms.
      await _storage.delete(key: _kBaseUrl);
      await _storage.delete(key: _kUsername);
      await _storage.delete(key: _kAccessToken);
    } on MissingPluginException {
      // Ignore if plugin is unavailable.
    } on PlatformException {
      // Ignore secure storage failures during logout.
    }
  }
}
