import 'dart:async';
import 'dart:io';

import 'package:database_service_wrapper/database_service_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DBSWSqfliteServiceImplementation implements DBSWSqfliteService {
  DBSWSqfliteServiceImplementation({
    required this.databaseFileName,
    this.defaultConflictAlgorithm = ConflictAlgorithm.ignore,
  }) : assert(
         databaseFileName.split('.').last == 'db',
         'File name format should be like this: Filename.db',
       ) {
    // Initialize FFI for Windows/macOS and Web
    if (Platform.isWindows || Platform.isMacOS) {
      // This will override the global databaseFactory
      databaseFactory = databaseFactoryFfi;
    } else if (kIsWeb) {
      // Use web factory for web platform
      databaseFactory = databaseFactoryFfiWeb;
    }
  }

  final String databaseFileName;
  final ConflictAlgorithm defaultConflictAlgorithm;
  Database? database;

  Future<String> _getSqliteDatabaseFullPath() async {
    try {
      if (kIsWeb) {
        // For web, just return the database name (stored in IndexedDB)
        return databaseFileName;
      } else {
        final path = await getDatabasesPath();
        return join(path, databaseFileName);
      }
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  @override
  Future<JobDone> openSqliteDatabase({
    int databaseVersion = 1,
    OnCreate onCreate,
    OnUpgrade onUpgrade,
    OnDowngrade onDowngrade,
    bool readOnly = false,
  }) async {
    try {
      final databasePath = await _getSqliteDatabaseFullPath();
      database = await databaseFactory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: databaseVersion,
          readOnly: readOnly,
          onConfigure: _onConfigure,
          onCreate: (db, version) => onCreate?.call(db, version),
          onUpgrade: (db, oldVersion, newVersion) =>
              onUpgrade?.call(db, oldVersion, newVersion),
          onDowngrade: (db, oldVersion, newVersion) =>
              onDowngrade?.call(db, oldVersion, newVersion),
        ),
      );
      return const JobDone();
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<JobDone> closeSqliteDatabase() async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database object was null');
      }
      await database!.close();
      return const JobDone();
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<JobDone> deleteSqliteDatabase() async {
    try {
      final databasePath = await _getSqliteDatabaseFullPath();
      await databaseFactory.deleteDatabase(databasePath);
      return const JobDone();
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
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
  }) async {
    try {
      final queryResult = await database!.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return queryResult;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
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
  }) async {
    try {
      final queryResult = await database!.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return queryResult.isNotEmpty ? queryResult.first : <String, Object?>{};
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<bool> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final result = await database!.insert(
        table,
        values,
        nullColumnHack: nullColumnHack,
        conflictAlgorithm: conflictAlgorithm ?? defaultConflictAlgorithm,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<bool> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    try {
      final result = await database!.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
        conflictAlgorithm: conflictAlgorithm ?? defaultConflictAlgorithm,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<bool> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      final result = await database!.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      if (result == 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<JobDone> excuteRawQuery(String sql, [List<Object?>? arguments]) async {
    try {
      await database!.execute(sql, arguments);
      return const JobDone();
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      return await database!.rawQuery(sql, arguments);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawInsert(sql, arguments);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawUpdate(sql, arguments);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    try {
      return await database!.rawDelete(sql, arguments);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<int> countRows(String table) async {
    try {
      final result = await database!.rawQuery('SELECT COUNT(*) FROM $table');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      return await database!.transaction(action);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<List<Object?>> executeBatch(
    void Function(SqfliteBatch batch) operations, {
    bool? exclusive,
    bool? noResult,
    bool? continueOnError,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final batch = database!.batch();
      operations(batch);
      return await batch.commit(
        exclusive: exclusive,
        noResult: noResult,
        continueOnError: continueOnError,
      );
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<int> count(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final result = await database!.rawQuery(
        'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<double?> sum(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final result = await database!.rawQuery(
        'SELECT SUM($column) as sum FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      return result.isNotEmpty ? result.first['sum'] as double? : null;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<double?> avg(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final result = await database!.rawQuery(
        'SELECT AVG($column) as avg FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      return result.isNotEmpty ? result.first['avg'] as double? : null;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<Object?> min(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final result = await database!.rawQuery(
        'SELECT MIN($column) as min FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      return result.isNotEmpty ? result.first['min'] : null;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
  Future<Object?> max(
    String table,
    String column, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }
      final result = await database!.rawQuery(
        'SELECT MAX($column) as max FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );
      return result.isNotEmpty ? result.first['max'] : null;
    } catch (e) {
      throw DBSWException(error: e);
    }
  }

  @override
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
  }) async {
    try {
      if (database == null) {
        throw const DBSWException(error: 'Database is not initialized');
      }

      // Build SELECT clause with aggregations
      final selectColumns = <String>[];

      // Add group by columns to select
      selectColumns.addAll(groupBy);

      // Add aggregation expressions
      for (final entry in aggregations.entries) {
        selectColumns.add('${entry.value} as ${entry.key}');
      }

      final selectClause = selectColumns.join(', ');

      // Build GROUP BY clause
      final groupByClause = groupBy.isNotEmpty
          ? ' GROUP BY ${groupBy.join(', ')}'
          : '';

      // Build HAVING clause
      final havingClause = having != null ? ' HAVING $having' : '';

      // Build ORDER BY clause
      final orderByClause = orderBy != null ? ' ORDER BY $orderBy' : '';

      // Build LIMIT and OFFSET clauses
      final limitClause = limit != null ? ' LIMIT $limit' : '';
      final offsetClause = offset != null ? ' OFFSET $offset' : '';

      // Build WHERE clause
      final whereClause = where != null ? ' WHERE $where' : '';

      final sql =
          'SELECT $selectClause FROM $table$whereClause$groupByClause$havingClause$orderByClause$limitClause$offsetClause';

      return await database!.rawQuery(sql, whereArgs);
    } catch (e) {
      throw DBSWException(error: e);
    }
  }
}
