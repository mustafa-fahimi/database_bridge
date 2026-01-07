# Database Bridge

[![pub package](https://img.shields.io/pub/v/database_bridge.svg)](https://pub.dev/packages/database_bridge)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A unified Flutter database service wrapper providing consistent APIs for SQL (Drift, Sqflite), NoSQL (Hive, ObjectBox), and secure storage with comprehensive functionality including encryption, transactions, and reactive streams.

## Installation

```yaml
dependencies:
  database_bridge: ^1.0.0
```

```bash
flutter pub get
```

## Supported Services

### 🔐 Hive (NoSQL with Encryption)
Fast key-value storage with optional AES encryption support.

**Core Methods:**
- `initializeDatabase()`, `closeDatabase()`, `deleteDatabaseFromDisk()`
- `write(box, key, value)`, `read(box, key)`, `update(box, key, value)`, `addOrUpdate(box, key, value)`, `delete(box, key)`
- `writeMultiple(box, entries)`, `deleteMultiple(box, keys)`, `clearBox(box)`
- `openBox(name)`, `closeBox(name)`, `deleteBoxFromDisk(name)`
- `hasProperty(box, key)`, `registerAdapter<T>(adapter)`

**Encryption Support:**
```dart
final security = DatabaseBridgeHiveSecurity();
await security.generateAndSaveSecureKeyIfNotExist();
final cipher = await security.readEncryptionCipher();
// Use cipher when opening encrypted boxes
```

### 🗄️ Sqflite (SQL Database)
Full-featured SQLite database with raw SQL support and aggregations.

**Core Methods:**
- `openSqliteDatabase(version, onCreate, onUpgrade, onDowngrade)`, `closeSqliteDatabase()`, `deleteSqliteDatabase()`
- `insert(table, values)`, `update(table, values, where, whereArgs)`, `delete(table, where, whereArgs)`
- `read(table, columns, where, whereArgs, orderBy, limit, offset)`, `readFirst(table, ...)`
- `rawQuery(sql, args)`, `rawInsert(sql, args)`, `rawUpdate(sql, args)`, `rawDelete(sql, args)`
- `excuteRawQuery(sql, args)`, `countRows(table)`, `count(table, where, whereArgs)`
- `transaction<T>(action)`, `executeBatch(operations)`
- Aggregations: `sum(table, column)`, `avg(table, column)`, `min(table, column)`, `max(table, column)`
- `aggregateQuery(table, groupBy, aggregations, having)`

### 🎯 Drift (Type-Safe SQL)
Advanced SQL with compile-time type safety, reactive streams, and complex querying.

**Core Methods:**
- `getAll<T, D>()`, `getSingle<T, D>(filter)`, `getFirstWhere<T, D>(conditions)`
- `insert<T, D>(entity)`, `update<T, D>(entity)`, `delete<T, D>(filter)`
- `batchInsert<T, D>(entities)`, `batchUpdate<T, D>(entities)`, `batchDelete<T, D>(filter)`
- Reactive: `watchAll<T, D>()`, `watchSingle<T, D>(filter)`, `watchFiltered<T, D>(filter)`
- Complex: `getWithComplexFilter()`, `getIn()`, `getLike()`, `getWithSorting()`
- Pagination: `getPaged()`, `getLimited()`, `getFirstSorted()`
- Aggregations: `count()`, `sum(column)`, `avg(column)`, `min(column)`, `max(column)`
- Raw SQL: `customSelect()`, `customUpdate()`, `customInsert()`, `customStatement()`
- `transaction<R>(action)`, `executeBatch(operations)`

### ⚡ ObjectBox (High-Performance NoSQL)
ACID-compliant object database with advanced querying capabilities.

**Core Methods:**
- `initializeStore()`, `closeStore()`, `clearAllData()`, `compact()`
- `put<T>(object)`, `putMany<T>(objects)`, `get<T>(id)`, `getAll<T>()`
- `remove<T>(id)`, `removeMany<T>(ids)`, `removeAll<T>()`, `contains<T>(id)`, `count<T>()`
- Querying: `query<T>(condition, orderBy, offset, limit)`, `queryFirst<T>(condition)`, `queryCount<T>(condition)`
- `runInTransaction<R>(action)`, `isStoreOpen()`, `store` (direct access)

### 🔒 Secure Storage
Encrypted key-value storage for sensitive data using platform-specific secure storage.

**Core Methods:**
- `initialize()`
- `write(key, value)`, `writeBatch(data)`, `read(key)`, `readAll()`
- `containsKey(key)`, `getKeys()`, `delete(key)`, `deleteAll()`

## Usage Examples

### Basic CRUD Operations
```dart
import 'package:database_bridge/database_bridge.dart';

// Hive
final hive = DatabaseBridgeHiveService();
await hive.initializeDatabase();
await hive.write('users', 'john', {'name': 'John', 'age': 30});
final user = await hive.read('users', 'john');

// Sqflite
final sqlite = DatabaseBridgeSqfliteService(databaseFileName: 'app.db');
await sqlite.openSqliteDatabase(databaseVersion: 1, onCreate: (db, v) async {
  await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
});
await sqlite.insert('users', {'name': 'John', 'age': 30});
final users = await sqlite.read('users');

// ObjectBox
final objectBox = DatabaseBridgeObjectboxService();
await objectBox.initializeStore();
final userObj = User(name: 'John', age: 30); // Your entity
await objectBox.put(userObj);
final users = await objectBox.getAll<User>();
```

### Transactions & Batch Operations
```dart
// Sqflite Transaction
await sqlite.transaction((txn) async {
  await txn.insert('users', {'name': 'Alice'});
  await txn.insert('users', {'name': 'Bob'});
});

// Sqflite Batch
await sqlite.executeBatch((batch) {
  batch.insert('users', {'name': 'Charlie'});
  batch.update('users', {'age': 25}, where: 'name = ?', whereArgs: ['Charlie']);
});

// ObjectBox Transaction
await objectBox.runInTransaction(() {
  objectBox.put(User(name: 'Alice'));
  objectBox.put(User(name: 'Bob'));
});
```

### Reactive Queries (Drift)
```dart
final drift = DatabaseBridgeDriftService(myDatabase);

// Reactive streams for real-time updates
drift.watchAll<UsersTable, User>().listen((users) {
  print('Users updated: ${users.length}');
});

// Filtered reactive queries
drift.watchFiltered<UsersTable, User>(
  (table) => table.age.isBiggerThanValue(18)
).listen((adults) {
  print('Adults: ${adults.length}');
});
```

### Error Handling
```dart
try {
  await service.write('box', 'key', 'value');
} on DatabaseBridgeException catch (e) {
  print('Database error: $e');
}
```

## Core Features

- **Unified API**: Consistent method signatures across all database types
- **Type Safety**: Full Dart type safety with generics and compile-time checks (Drift)
- **Encryption**: AES encryption for Hive with secure key management
- **Transactions**: ACID-compliant transactions for data integrity
- **Batch Operations**: Multiple operations in single atomic transactions
- **Reactive Streams**: Real-time data updates and change notifications (Drift)
- **Raw SQL Support**: Direct SQL execution when needed (Sqflite, Drift)
- **Aggregations**: Built-in statistical functions (count, sum, avg, min, max)
- **Advanced Querying**: Complex filters, sorting, pagination, and grouping
- **Cross-Platform**: Native support for iOS, Android, Web, and Desktop
- **Error Handling**: Comprehensive `DatabaseBridgeException` with detailed error information

## Return Types

- **JobDone**: Success confirmation for operations like initialization, clearing data
- **DatabaseBridgeException**: Unified error handling with original error details
- **Service-specific**: Maps, Lists, Streams, primitives, and custom objects as documented

## License

MIT License - see [LICENSE](LICENSE)
