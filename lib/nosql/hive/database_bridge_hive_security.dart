import 'dart:convert';

import 'package:database_bridge/database_bridge.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// A class that handles the security of a NoSQL database by generating
/// and storing an encryption key for AES data encryption.
/// It uses FlutterSecureStorage to securely store the encryption key.
class DatabaseBridgeHiveSecurity {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _secureKey = 'Y2xhc29y';

  /// This method reads the secure key from the secure storage.
  /// If the key does not exist,
  /// it generates a new key and saves it to the secure storage.
  /// If the key already exists, this method does nothing.
  ///
  /// Throws a [DatabaseServiceException] if an error occurs while reading or
  /// writing the secure key.
  Future<void> generateAndSaveSecureKeyIfNotExist() async {
    try {
      final secureStorageKey = await _secureStorage.read(key: _secureKey);
      if (secureStorageKey == null) {
        await _writeSecureKey();
      }
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  List<int> _generateNewSecureKey() => Hive.generateSecureKey();

  /// This method generates a new secure key and writes it to the secure storage
  /// using the [_secureStorage] instance.
  /// The key is written with the [KeychainAccessibility.first_unlock]
  /// accessibility option on iOS and macOS.
  /// If an error occurs during the write operation,
  /// a [DatabaseServiceException] is thrown with the appropriate
  /// action and error message.
  Future<void> _writeSecureKey() async {
    try {
      await _secureStorage.write(
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: const MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        key: _secureKey,
        value: base64UrlEncode(_generateNewSecureKey()),
      );
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  Future<void> deleteSecureKey() async {
    try {
      await _secureStorage.delete(key: _secureKey);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  /// Reads the encryption cipher from secure storage and returns
  /// a [HiveCipher] object.
  ///
  /// The [HiveCipher] object is used to encrypt and decrypt data in the
  /// database.
  ///
  /// This method reads the encryption key from secure storage, decodes
  /// it from base64Url, and returns a [HiveAesCipher] object initialized with
  /// the encryption key.
  ///
  /// If the secure key is null, a [DatabaseServiceException] is thrown set
  /// to 'Secure key is null'.
  ///
  /// If an error occurs while reading the secure key
  /// a [DatabaseServiceException] is thrown.
  Future<HiveCipher> readEncryptionCipher() async {
    try {
      final secureStorageKey = await _secureStorage.read(
        key: _secureKey,
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        mOptions: const MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

      if (secureStorageKey != null) {
        final encryptionKey = base64Url.decode(secureStorageKey);
        return HiveAesCipher(encryptionKey);
      } else {
        throw const DatabaseBridgeException(error: 'Secure key is null');
      }
    } catch (e) {
      throw DatabaseBridgeException(error: e.toString());
    }
  }
}
