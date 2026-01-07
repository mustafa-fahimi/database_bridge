import 'package:database_service_wrapper/database_service_wrapper.dart';

abstract interface class DBSWSecureStorageService {
  const DBSWSecureStorageService();

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
