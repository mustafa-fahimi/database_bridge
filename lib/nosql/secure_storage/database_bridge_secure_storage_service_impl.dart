import 'package:database_bridge/common/database_bridge_exception.dart';
import 'package:database_bridge/common/job_done.dart';
import 'package:database_bridge/nosql/secure_storage/database_bridge_secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseBridgeSecureStorageServiceImpl
    implements DatabaseBridgeSecureStorageService {
  DatabaseBridgeSecureStorageServiceImpl();

  FlutterSecureStorage? _storage;
  bool _isInitialized = false;

  FlutterSecureStorage get _getStorage {
    if (!_isInitialized || _storage == null) {
      throw DatabaseBridgeException(
        error: 'SecureStorageService not initialized. Call initialize() first.',
      );
    }
    return _storage!;
  }

  @override
  Future<JobDone> initialize() async {
    try {
      _storage = const FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(),
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
        wOptions: WindowsOptions(useBackwardCompatibility: false),
      );
      _isInitialized = true;
      return const JobDone();
    } catch (e) {
      throw DatabaseBridgeException(error: 'Failed to initialize secure storage: $e');
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (key.isEmpty) {
      throw DatabaseBridgeException(error: 'Key cannot be empty');
    }
    if (value.isEmpty) {
      throw DatabaseBridgeException(error: 'Value cannot be empty');
    }

    try {
      await _getStorage.write(key: key, value: value);
    } catch (e) {
      throw DatabaseBridgeException(
        error: 'Failed to write secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<void> writeBatch(Map<String, String> data) async {
    if (data.isEmpty) {
      throw DatabaseBridgeException(error: 'Data map cannot be empty');
    }

    for (final entry in data.entries) {
      if (entry.key.isEmpty) {
        throw DatabaseBridgeException(error: 'Key cannot be empty');
      }
      if (entry.value.isEmpty) {
        throw DatabaseBridgeException(
          error: 'Value cannot be empty for key "${entry.key}"',
        );
      }
    }

    try {
      for (final entry in data.entries) {
        await _getStorage.write(key: entry.key, value: entry.value);
      }
    } catch (e) {
      throw DatabaseBridgeException(error: 'Failed to write batch data: $e');
    }
  }

  @override
  Future<String?> read(String key) async {
    if (key.isEmpty) {
      throw DatabaseBridgeException(error: 'Key cannot be empty');
    }

    try {
      final result = await _getStorage.read(key: key);
      return result;
    } catch (e) {
      throw DatabaseBridgeException(
        error: 'Failed to read secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    if (key.isEmpty) {
      throw DatabaseBridgeException(error: 'Key cannot be empty');
    }

    try {
      final result = await _getStorage.containsKey(key: key);
      return result;
    } catch (e) {
      throw DatabaseBridgeException(
        error: 'Failed to check key existence for "$key": $e',
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      final result = await _getStorage.readAll();
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: 'Failed to read all secure data: $e');
    }
  }

  @override
  Future<List<String>> getKeys() async {
    try {
      final data = await _getStorage.readAll();
      return data.keys.toList();
    } catch (e) {
      throw DatabaseBridgeException(error: 'Failed to get keys: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    if (key.isEmpty) {
      throw DatabaseBridgeException(error: 'Key cannot be empty');
    }

    try {
      await _getStorage.delete(key: key);
    } catch (e) {
      throw DatabaseBridgeException(
        error: 'Failed to delete secure data for key "$key": $e',
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _getStorage.deleteAll();
    } catch (e) {
      throw DatabaseBridgeException(error: 'Failed to delete all secure data: $e');
    }
  }

  Future<void> dispose() async {
    _storage = null;
    _isInitialized = false;
  }
}
