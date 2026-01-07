import 'package:drift/drift.dart';

typedef BatchOperation = void Function(Batch batch);

abstract interface class DBSWDriftService {
  const DBSWDriftService();

  Future<List<D>> getAll<T extends Table, D>();

  Future<D?> getSingle<T extends Table, D>(Expression<bool> Function(T) filter);

  Future<int> insert<T extends Table, D>(
    Insertable<D> entity, {
    InsertMode mode = InsertMode.insertOrAbort,
    UpsertClause<T, D>? onConflict,
  });

  Future<bool> update<T extends Table, D>(Insertable<D> entity);

  Future<int> delete<T extends Table, D>(Expression<bool> Function(T) filter);

  Future<void> closeDatabase();

  Future<List<int>> batchInsert<T extends Table, D>(
    List<Insertable<D>> entities, {
    InsertMode mode = InsertMode.insertOrAbort,
    UpsertClause<T, D>? onConflict,
  });

  Future<List<bool>> batchUpdate<T extends Table, D>(
    List<Insertable<D>> entities,
  );

  Future<int> batchDelete<T extends Table, D>(
    Expression<bool> Function(T) filter,
  );

  Future<void> executeBatch(List<BatchOperation> operations);

  Stream<List<D>> watchAll<T extends Table, D>();

  Stream<List<D>> watchFiltered<T extends Table, D>(
    Expression<bool> Function(T) filter,
  );

  Stream<D?> watchSingle<T extends Table, D>(
    Expression<bool> Function(T) filter,
  );

  Future<R> transaction<R>(Future<R> Function() action);

  Future<List<T>> customSelect<T>(
    String query, {
    List<Variable<Object>>? variables,
  });

  Future<int> customUpdate(String query, {List<Variable<Object>>? variables});

  Future<int> customInsert(String query, {List<Variable<Object>>? variables});

  Future<void> customStatement(
    String query, {
    List<Variable<Object>>? variables,
  });

  Future<List<D>> getWithComplexFilter<T extends Table, D>(
    List<Expression<bool>> filters, {
    bool andLogic = true,
  });

  Future<List<D>> getIn<T extends Table, D>(
    Expression column,
    List<Object?> values,
  );

  Future<List<D>> getLike<T extends Table, D>(
    Expression<String> column,
    String pattern,
  );

  Future<D?> getFirstWhere<T extends Table, D>(
    List<Expression<bool>> conditions, {
    bool andLogic = true,
  });

  Future<List<D>> getWithSorting<T extends Table, D>(
    List<OrderingTerm Function(T)> orderBy, {
    Expression<bool> Function(T)? filter,
    int? limit,
    int? offset,
  });

  Future<List<D>> getPaged<T extends Table, D>({
    Expression<bool> Function(T)? filter,
    List<OrderClauseGenerator<T>>? orderBy,
    required int limit,
    required int offset,
  });

  Future<List<D>> getLimited<T extends Table, D>(
    int limit, {
    Expression<bool> Function(T)? filter,
    List<OrderClauseGenerator<T>>? orderBy,
  });

  Future<D?> getFirstSorted<T extends Table, D>(
    List<OrderingTerm Function(T)> orderBy, {
    Expression<bool> Function(T)? filter,
  });

  Future<int> count<T extends Table, D>({
    Expression<bool>? filter,
  });

  Future<double?> sum<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  });

  Future<double?> avg<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  });

  Future<Object?> min<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  });

  Future<Object?> max<T extends Table, D>(
    String columnName, {
    Expression<bool>? filter,
  });

  Future<List<Map<String, Object?>>> aggregateWithGroupBy<T extends Table, D>({
    required List<String> groupByColumns,
    required Map<String, String> aggregations,
    Expression<bool>? filter,
    String? having,
  });
}
