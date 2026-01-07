import 'package:database_bridge/database_bridge.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class DatabaseBridgeHiveService {

  Future<JobDone> initializeDatabase();

  Future<JobDone> closeDatabase();

  Future<Box<dynamic>> openBox(String boxName);

  Future<JobDone> closeBox(String boxName);

  Future<JobDone> write(String boxName, String key, dynamic value);

  Future<JobDone> writeMultiple(String boxName, Map<dynamic, dynamic> enteries);

  Future<dynamic> read(String boxName, String key, {dynamic defaultValue});

  Future<JobDone> update(String boxName, String key, dynamic value);

  Future<JobDone> addOrUpdate(String boxName, String key, dynamic value);

  Future<JobDone> delete(String boxName, String key);

  Future<JobDone> deleteMultiple(String boxName, Iterable<dynamic> keys);

  Future<int> clearBox(String boxName);

  Future<JobDone> deleteBoxFromDisk(String boxName);

  Future<JobDone> deleteDatabaseFromDisk();

  Future<bool> hasProperty(String boxName, String key);

  Future<JobDone> registerAdapter<T>(
    TypeAdapter<T> adapter, {
    bool override = false,
  });
}
