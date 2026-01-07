import 'package:database_bridge/common/job_done.dart';
import 'package:objectbox/objectbox.dart';

abstract interface class DatabaseBridgeObjectboxService {

  Future<JobDone> initializeStore();

  Future<JobDone> closeStore();

  Future<T?> get<T>(int id);

  Future<List<T>> getAll<T>();

  Future<int> put<T>(T object);

  Future<List<int>> putMany<T>(List<T> objects);

  Future<bool> remove<T>(int id);

  Future<int> removeMany<T>(List<int> ids);

  Future<int> removeAll<T>();

  Future<bool> contains<T>(int id);

  Future<int> count<T>();

  Future<List<T>> query<T>(
    Condition<T>? condition, {
    QueryProperty<T, dynamic>? orderBy,
    int? flags,
    int? offset,
    int? limit,
  });

  Future<T?> queryFirst<T>(
    Condition<T>? condition, {
    QueryProperty<T, dynamic>? orderBy,
    int? flags,
  });

  Future<int> queryCount<T>(Condition<T>? condition);

  Future<R> runInTransaction<R>(R Function() action);

  Future<JobDone> clearAllData();

  Future<JobDone> compact();

  bool isStoreOpen();

  Store? get store;
}
