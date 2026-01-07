import 'package:database_bridge/common/database_bridge_exception.dart';
import 'package:database_bridge/sql/drift/database_bridge_drift_service.dart';
import 'package:drift/drift.dart';

class DatabaseBridgeDriftServiceImpl implements DatabaseBridgeDriftService {
  const DatabaseBridgeDriftServiceImpl(this._database);

  final GeneratedDatabase _database;

  @override
  Future<List<D>> getAll<T extends Table, D>() async {
    try {
      final table = _getTable<T, D>();
      final result = await _database.select(table).get();
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<D?> getSingle<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) async {
    try {
      final table = _getTable<T, D>();
      final result = await (_database.select(
        table,
      )..where(filter)).getSingleOrNull();
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> insert<T extends Table, D>(
    Insertable<D> entity, {
    InsertMode mode = InsertMode.insertOrAbort,
    UpsertClause<T, D>? onConflict,
  }) async {
    try {
      final table = _getTable<T, D>();
      final result = await _database
          .into(table)
          .insert(entity, mode: mode, onConflict: onConflict);
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<bool> update<T extends Table, D>(Insertable<D> entity) async {
    try {
      final table = _getTable<T, D>();
      final result = await _database.update(table).replace(entity);
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> delete<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) async {
    try {
      final table = _getTable<T, D>();
      final result = await (_database.delete(table)..where(filter)).go();
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<void> closeDatabase() async {
    try {
      await _database.close();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<int>> batchInsert<T extends Table, D>(
    List<Insertable<D>> entities, {
    InsertMode mode = InsertMode.insertOrAbort,
    UpsertClause<T, D>? onConflict,
  }) async {
    try {
      final table = _getTable<T, D>();
      final results = <int>[];

      for (final entity in entities) {
        final result = await _database
            .into(table)
            .insert(entity, mode: mode, onConflict: onConflict);
        results.add(result);
      }

      return results;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<bool>> batchUpdate<T extends Table, D>(
    List<Insertable<D>> entities,
  ) async {
    try {
      final table = _getTable<T, D>();
      final results = <bool>[];

      for (final entity in entities) {
        final result = await _database.update(table).replace(entity);
        results.add(result);
      }

      return results;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> batchDelete<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) async {
    try {
      final table = _getTable<T, D>();
      final result = await (_database.delete(table)..where(filter)).go();
      return result;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<void> executeBatch(List<BatchOperation> operations) async {
    try {
      await _database.batch((batch) {
        for (final operation in operations) {
          operation(batch);
        }
      });
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Stream<List<D>> watchAll<T extends Table, D>() {
    try {
      final table = _getTable<T, D>();
      return _database.select(table).watch();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Stream<List<D>> watchFiltered<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) {
    try {
      final table = _getTable<T, D>();
      return (_database.select(table)..where(filter)).watch();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Stream<D?> watchSingle<T extends Table, D>(
    Expression<bool> Function(T) filter,
  ) {
    try {
      final table = _getTable<T, D>();
      return (_database.select(table)..where(filter)).watchSingleOrNull();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<R> transaction<R>(Future<R> Function() action) async {
    try {
      return await _database.transaction(action);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<T>> customSelect<T>(
    String query, {
    List<Variable<Object>>? variables,
  }) async {
    try {
      final statement = _database.customSelect(
        query,
        variables: variables ?? [],
      );
      final result = await statement.get();
      return result as List<T>;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> customUpdate(
    String query, {
    List<Variable<Object>>? variables,
  }) async {
    try {
      return await _database.customUpdate(query, variables: variables ?? []);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> customInsert(
    String query, {
    List<Variable<Object>>? variables,
  }) async {
    try {
      return await _database.customInsert(query, variables: variables ?? []);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<void> customStatement(
    String query, {
    List<Variable<Object>>? variables,
  }) async {
    try {
      await _database.customStatement(query);
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getWithComplexFilter<T extends Table, D>(
    List<Expression<bool>> filters, {
    bool andLogic = true,
  }) async {
    try {
      final table = _getTable<T, D>();
      Expression<bool>? combinedFilter;

      for (final filter in filters) {
        if (combinedFilter == null) {
          combinedFilter = filter;
        } else {
          combinedFilter = andLogic
              ? combinedFilter & filter
              : combinedFilter | filter;
        }
      }

      if (combinedFilter == null) {
        return await _database.select(table).get();
      }

      return await (_database.select(
        table,
      )..where((_) => combinedFilter!)).get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getIn<T extends Table, D>(
    Expression<Object?> column,
    List<Object?> values,
  ) async {
    try {
      final table = _getTable<T, D>();
      return await (_database.select(
        table,
      )..where((_) => column.isIn(values))).get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getLike<T extends Table, D>(
    Expression<String> column,
    String pattern,
  ) async {
    try {
      final table = _getTable<T, D>();
      return await (_database.select(
        table,
      )..where((_) => column.like(pattern))).get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<D?> getFirstWhere<T extends Table, D>(
    List<Expression<bool>> conditions, {
    bool andLogic = true,
  }) async {
    try {
      final table = _getTable<T, D>();
      Expression<bool>? combinedCondition;

      for (final condition in conditions) {
        if (combinedCondition == null) {
          combinedCondition = condition;
        } else {
          combinedCondition = andLogic
              ? combinedCondition & condition
              : combinedCondition | condition;
        }
      }

      if (combinedCondition == null) {
        return await (_database.select(table)..limit(1)).getSingleOrNull();
      }

      return await (_database.select(table)
            ..where((_) => combinedCondition!)
            ..limit(1))
          .getSingleOrNull();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getWithSorting<T extends Table, D>(
    List<OrderingTerm Function(T)> orderBy, {
    Expression<bool> Function(T)? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      final table = _getTable<T, D>();
      var query = _database.select(table);

      if (filter != null) {
        query = query..where(filter);
      }

      query = query..orderBy(orderBy);

      if (limit != null) {
        query = query..limit(limit, offset: offset);
      }

      return await query.get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getPaged<T extends Table, D>({
    Expression<bool> Function(T)? filter,
    List<OrderingTerm Function(T)>? orderBy,
    required int limit,
    required int offset,
  }) async {
    try {
      final table = _getTable<T, D>();
      var query = _database.select(table);

      if (filter != null) {
        query = query..where(filter);
      }

      if (orderBy != null && orderBy.isNotEmpty) {
        query = query..orderBy(orderBy);
      }

      query = query..limit(limit, offset: offset);

      return await query.get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<D>> getLimited<T extends Table, D>(
    int limit, {
    Expression<bool> Function(T)? filter,
    List<OrderingTerm Function(T)>? orderBy,
  }) async {
    try {
      final table = _getTable<T, D>();
      var query = _database.select(table);

      if (filter != null) {
        query = query..where(filter);
      }

      if (orderBy != null && orderBy.isNotEmpty) {
        query = query..orderBy(orderBy);
      }

      query = query..limit(limit);

      return await query.get();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<D?> getFirstSorted<T extends Table, D>(
    List<OrderingTerm Function(T)> orderBy, {
    Expression<bool> Function(T)? filter,
  }) async {
    try {
      final table = _getTable<T, D>();
      var query = _database.select(table);

      if (filter != null) {
        query = query..where(filter);
      }

      query = query
        ..orderBy(orderBy)
        ..limit(1);

      return await query.getSingleOrNull();
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<int> count<T extends Table, D>({Expression<bool>? filter}) async {
    try {
      final table = _getTable<T, D>();
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT COUNT(*) as count FROM ${table.actualTableName}$whereClause';
      final results = await _database.customSelect(sql).get();

      if (results.isEmpty) return 0;
      return results.first.data['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<double?> sum<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  }) async {
    try {
      final table = _getTable<T, D>();
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT SUM($columnName) as sum FROM ${table.actualTableName}$whereClause';
      final results = await _database.customSelect(sql).get();

      if (results.isEmpty) return null;
      return results.first.data['sum'] as double?;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<double?> avg<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  }) async {
    try {
      final table = _getTable<T, D>();
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT AVG($columnName) as avg FROM ${table.actualTableName}$whereClause';
      final results = await _database.customSelect(sql).get();

      if (results.isEmpty) return null;
      return results.first.data['avg'] as double?;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<Object?> min<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  }) async {
    try {
      final table = _getTable<T, D>();
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT MIN($columnName) as min FROM ${table.actualTableName}$whereClause';
      final results = await _database.customSelect(sql).get();

      if (results.isEmpty) return null;
      return results.first.data['min'];
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<Object?> max<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  }) async {
    try {
      final table = _getTable<T, D>();
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT MAX($columnName) as max FROM ${table.actualTableName}$whereClause';
      final results = await _database.customSelect(sql).get();

      if (results.isEmpty) return null;
      return results.first.data['max'];
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  @override
  Future<List<Map<String, Object?>>> aggregateWithGroupBy<T extends Table, D>({
    required List<String> groupByColumns,
    required Map<String, String> aggregations,
    Expression<bool>? filter,
    String? having,
  }) async {
    try {
      final table = _getTable<T, D>();

      final selectParts = <String>[];

      selectParts.addAll(groupByColumns);

      for (final entry in aggregations.entries) {
        selectParts.add('${entry.value} as ${entry.key}');
      }

      final selectClause = selectParts.join(', ');
      final groupByClause = groupByColumns.isNotEmpty
          ? ' GROUP BY ${groupByColumns.join(', ')}'
          : '';
      final havingClause = having != null ? ' HAVING $having' : '';
      final whereClause = filter != null ? ' WHERE $filter' : '';

      final sql =
          'SELECT $selectClause FROM ${table.actualTableName}$whereClause$groupByClause$havingClause';

      final results = await _database.customSelect(sql).get();

      final List<Map<String, Object?>> mappedResults = [];
      for (final result in results) {
        final Map<String, Object?> row = {};

        for (final key in result.data.keys) {
          row[key] = result.data[key];
        }

        mappedResults.add(row);
      }

      return mappedResults;
    } catch (e) {
      throw DatabaseBridgeException(error: e);
    }
  }

  TableInfo<T, D> _getTable<T extends Table, D>() {
    final table =
        _database.allTables.firstWhere((t) => t is T) as TableInfo<T, D>;
    return table;
  }
}
