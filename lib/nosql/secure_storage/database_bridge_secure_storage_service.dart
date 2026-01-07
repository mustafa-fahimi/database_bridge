import 'package:database_bridge/database_bridge.dart';
import 'package:database_bridge/nosql/secure_storage/database_bridge_secure_storage_service_impl.dart';

abstract interface class DatabaseBridgeSecureStorageService {
  factory DatabaseBridgeSecureStorageService() {
    return DatabaseBridgeSecureStorageServiceImpl();
  }

  Future<JobDone> initialize();

  Future<void> write(String key, String value);

  Future<void> writeBatch(Map<String, String> data);

  Future<String?> read(String key);

  Future<bool> containsKey(String key);

  Future<Map<String, String>> readAll();

  Future<List<String>> getKeys();

  Future<void> delete(String key);

  Future<void> deleteAll();
}
