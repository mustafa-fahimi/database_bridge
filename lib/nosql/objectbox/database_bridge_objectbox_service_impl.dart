import 'dart:io';

import 'package:database_bridge/common/database_bridge_exception.dart';
import 'package:database_bridge/common/job_done.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database_bridge_objectbox_service.dart';

class DatabaseBridgeObjectboxServiceImpl
    implements DatabaseBridgeObjectboxService {
  DatabaseBridgeObjectboxServiceImpl({this.storeDirectory, this.storeFactory});

  final Directory? storeDirectory;
  final Future<Store> Function(String directory)? storeFactory;
  Store? _store;

  @override
  Store? get store => _store;

  @override
  Future<JobDone> initializeStore() async {
    try {
      if (_store != null) {
        return const JobDone();
      }

      if (storeFactory == null) {
        throw const DatabaseBridgeException(
          error:
              'Store factory is required. Please provide a store factory function that returns a Store instance.',
        );
      }

      final directory = await _getStoreDirectory();
      _store = await storeFactory!(directory.path);

      return const JobDone();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  Future<Directory> _getStoreDirectory() async {
    if (storeDirectory != null) {
      if (!await storeDirectory!.exists()) {
        await storeDirectory!.create(recursive: true);
      }
      return storeDirectory!;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final storeDir = Directory(p.join(appDocDir.path, 'objectbox'));
    if (!await storeDir.exists()) {
      await storeDir.create(recursive: true);
    }
    return storeDir;
  }

  @override
  Future<JobDone> closeStore() async {
    try {
      if (_store != null) {
        _store!.close();
        _store = null;
      }
      return const JobDone();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  void _ensureStoreInitialized() {
    if (_store == null) {
      throw const DatabaseBridgeException(
        error: 'Store not initialized. Call initializeStore() first.',
      );
    }
  }

  @override
  Future<T?> get<T>(int id) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.get(id);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<T>> getAll<T>() async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.getAll();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> put<T>(T object) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.put(object);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<int>> putMany<T>(List<T> objects) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.putMany(objects);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<bool> remove<T>(int id) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.remove(id);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> removeMany<T>(List<int> ids) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.removeMany(ids);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> removeAll<T>() async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.removeAll();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<bool> contains<T>(int id) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.contains(id);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> count<T>() async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      return box.count();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<T>> query<T>(
    Condition<T>? condition, {
    QueryProperty<T, dynamic>? orderBy,
    int? flags,
    int? offset,
    int? limit,
  }) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      final queryBuilder = box.query(condition);

      if (orderBy != null && flags != null) {
        queryBuilder.order(orderBy, flags: flags);
      }

      final query = queryBuilder.build();
      return query.find();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<T?> queryFirst<T>(
    Condition<T>? condition, {
    QueryProperty<T, dynamic>? orderBy,
    int? flags,
  }) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      final queryBuilder = box.query(condition);

      if (orderBy != null && flags != null) {
        queryBuilder.order(orderBy, flags: flags);
      }

      final query = queryBuilder.build();
      return query.findFirst();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> queryCount<T>(Condition<T>? condition) async {
    try {
      _ensureStoreInitialized();
      final box = _store!.box<T>();
      final query = box.query(condition).build();
      return query.count();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<R> runInTransaction<R>(R Function() action) async {
    try {
      _ensureStoreInitialized();
      return _store!.runInTransaction(TxMode.write, action);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<JobDone> clearAllData() async {
    try {
      _ensureStoreInitialized();

      final storeDirectory = await _getStoreDirectory();

      _store!.close();
      _store = null;

      Store.removeDbFiles(storeDirectory.path);

      if (storeFactory != null) {
        _store = await storeFactory!(storeDirectory.path);
      }

      return const JobDone();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<JobDone> compact() async {
    try {
      _ensureStoreInitialized();
      await _store!.runInTransaction(TxMode.write, () {
        // ObjectBox automatically manages compaction
        // This is a no-op but maintains the interface
      });
      return const JobDone();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  bool isStoreOpen() {
    return _store != null && !_store!.isClosed();
  }
}
