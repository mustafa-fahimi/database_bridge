import 'dart:async';

import 'package:database_bridge/database_bridge.dart';
import 'package:sqflite/sqflite.dart';

typedef SqfliteBatch = Batch;
typedef OnCreate = FutureOr<void> Function(Database, int)?;
typedef OnUpgrade = FutureOr<void> Function(Database, int, int)?;
typedef OnDowngrade = FutureOr<void> Function(Database, int, int)?;

abstract interface class DatabaseBridgeSqfliteService {

  Future<JobDone> openSqliteDatabase({
    int databaseVersion = 1,
    OnCreate onCreate,
    OnUpgrade onUpgrade,
    OnDowngrade onDowngrade,
    bool readOnly = false,
  });

  Future<JobDone> closeSqliteDatabase();

  Future<JobDone> deleteSqliteDatabase();

  Future<List<Map<String, Object?>>> read(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<Map<String, Object?>> readFirst(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<bool> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm conflictAlgorithm,
  });

  Future<bool> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<bool> delete(String table, {String? where, List<Object?>? whereArgs});

  /// Executes a raw SQL query with optional arguments and returns
  /// a [Future] that completes with a [JobDone] object.
  ///
  /// The [sql] parameter is the raw SQL query to execute.
  ///
  /// The [arguments] parameter is an optional list of arguments
  ///  to replace placeholders in the [sql] query.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await excuteRawQuery(
  ///   'SELECT * FROM users WHERE age > ?', [18],
  /// );
  /// ```
  Future<JobDone> excuteRawQuery(String sql, [List<Object?>? arguments]);

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<int> rawInsert(String sql, [List<Object?>? arguments]);

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]);

  Future<int> rawDelete(String sql, [List<Object?>? arguments]);

  Future<int> countRows(String table);

  Future<int> count(String table, {String? where, List<Object?>? whereArgs});

  Future<double?> sum(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<double?> avg(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<Object?> min(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<Object?> max(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  });

  Future<List<Map<String, Object?>>> aggregateQuery(
    String table, {
    required List<String> groupBy,
    required Map<String, String> aggregations,
    String? where,
    List<Object?>? whereArgs,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action);

  Future<List<Object?>> executeBatch(
    void Function(SqfliteBatch batch) operations, {
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  });
}
