# database_bridge

[![pub package](https://img.shields.io/pub/v/database_bridge.svg)](https://pub.dev/packages/database_bridge)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A unified Flutter database service wrapper providing consistent APIs for SQL (Drift, Sqflite), NoSQL (Hive, ObjectBox), and secure storage with comprehensive functionality including encryption, transactions, and reactive streams. This package eliminates the complexity of managing multiple database implementations by offering a single, intuitive interface for all your data persistence needs.

---

## Table of Contents

- [database\_bridge](#database_bridge)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Installation](#installation)
  - [Quick Start](#quick-start)
  - [Usage](#usage)
    - [Hive (NoSQL with Encryption)](#hive-nosql-with-encryption)
    - [Sqflite (SQL Database)](#sqflite-sql-database)
    - [Drift (Type-Safe SQL)](#drift-type-safe-sql)
    - [ObjectBox (High-Performance NoSQL)](#objectbox-high-performance-nosql)
    - [Secure Storage](#secure-storage)
  - [API Reference](#api-reference)
    - [Classes](#classes)
      - [`DatabaseBridgeException`](#databasebridgeexception)
      - [`JobDone`](#jobdone)
      - [`DatabaseBridgeHiveService`](#databasebridgehiveservice)
      - [`DatabaseBridgeHiveSecurity`](#databasebridgehivesecurity)
      - [`DatabaseBridgeSqfliteService`](#databasebridgesqfliteservice)
      - [`DatabaseBridgeDriftService`](#databasebridgedriftservice)
      - [`DatabaseBridgeObjectboxService`](#databasebridgeobjectboxservice)
      - [`DatabaseBridgeSecureStorageService`](#databasebridgesecurestorageservice)
    - [Typedefs](#typedefs)
      - [`SqfliteBatch`](#sqflitebatch)
      - [`OnCreate`](#oncreate)
      - [`OnUpgrade`](#onupgrade)
      - [`OnDowngrade`](#ondowngrade)
      - [`BatchOperation`](#batchoperation)
  - [Complete Examples](#complete-examples)
    - [Multi-Service Application](#multi-service-application)
    - [Transaction Management](#transaction-management)
  - [License](#license)

---

## Features

- ✅ **Unified API**: Consistent method signatures across all database types (SQL, NoSQL, Secure Storage)
- ✅ **Multiple Database Support**: Hive, Sqflite, Drift, ObjectBox, and Secure Storage in one package
- ✅ **Type Safety**: Full Dart type safety with generics and compile-time checks (Drift)
- ✅ **Encryption**: AES encryption for Hive with secure key management via platform-specific secure storage
- ✅ **Transactions**: ACID-compliant transactions for data integrity across all services
- ✅ **Batch Operations**: Multiple operations in single atomic transactions
- ✅ **Reactive Streams**: Real-time data updates and change notifications (Drift)
- ✅ **Raw SQL Support**: Direct SQL execution when needed (Sqflite, Drift)
- ✅ **Aggregations**: Built-in statistical functions (count, sum, avg, min, max)
- ✅ **Advanced Querying**: Complex filters, sorting, pagination, and grouping
- ✅ **Cross-Platform**: Native support for iOS, Android, Web, and Desktop
- ✅ **Error Handling**: Comprehensive `DatabaseBridgeException` with detailed error information

---

## Installation

```yaml
dependencies:
  database_bridge: ^1.0.0
```

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:database_bridge/database_bridge.dart';

// Initialize and use Hive for simple key-value storage
final hive = DatabaseBridgeHiveService();
await hive.initializeDatabase();
await hive.write('users', 'john', {'name': 'John', 'age': 30});
final user = await hive.read('users', 'john');
```

---

## Usage

### Hive (NoSQL with Encryption)

Fast key-value storage with optional AES encryption support for secure data persistence.

**Basic Operations:**
```dart
final hive = DatabaseBridgeHiveService();
await hive.initializeDatabase();

// Write and read data
await hive.write('users', 'john', {'name': 'John', 'age': 30});
final user = await hive.read('users', 'john'); // Returns Map or defaultValue

// Batch operations
await hive.writeMultiple('users', {
  'jane': {'name': 'Jane', 'age': 25},
  'bob': {'name': 'Bob', 'age': 35}
});

// Check existence and delete
final exists = await hive.hasProperty('users', 'john');
await hive.delete('users', 'john');
```

**Encryption Setup:**
```dart
// Set up encryption for sensitive data
final security = DatabaseBridgeHiveSecurity();
await security.generateAndSaveSecureKeyIfNotExist();
final cipher = await security.readEncryptionCipher();

// Note: Encryption is typically handled at the Hive box level
// The DatabaseBridgeHiveSecurity class manages the encryption keys
// that can be used with standard Hive boxes for encryption
```

---

### Sqflite (SQL Database)

Full-featured SQLite database with raw SQL support, aggregations, and advanced querying capabilities.

**Database Setup and Basic CRUD:**
```dart
final sqlite = DatabaseBridgeSqfliteService(databaseFileName: 'app.db');

await sqlite.openSqliteDatabase(
  databaseVersion: 1,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER,
        email TEXT UNIQUE
      )
    ''');
  }
);

// CRUD Operations
await sqlite.insert('users', {
  'name': 'John Doe',
  'age': 30,
  'email': 'john@example.com'
});

final users = await sqlite.read('users', where: 'age > ?', whereArgs: [18]);
await sqlite.update('users', {'age': 31}, where: 'name = ?', whereArgs: ['John Doe']);
await sqlite.delete('users', where: 'age < ?', whereArgs: [21]);
```

**Raw SQL and Aggregations:**
```dart
// Raw SQL queries
final result = await sqlite.rawQuery('SELECT * FROM users WHERE age > ?', [21]);
await sqlite.rawInsert('INSERT INTO users (name, age) VALUES (?, ?)', ['Alice', 25]);

// Built-in aggregations
final userCount = await sqlite.countRows('users');
final avgAge = await sqlite.avg('users', 'age');
final totalAge = await sqlite.sum('users', 'age');
final oldestUser = await sqlite.max('users', 'age');

// Complex aggregations with grouping
final ageStats = await sqlite.aggregateQuery(
  'users',
  groupBy: ['age'],
  aggregations: {'count': 'COUNT(*)'},
  having: 'COUNT(*) > 1'
);
```

---

### Drift (Type-Safe SQL)

Advanced SQL with compile-time type safety, reactive streams, and complex querying using Drift ORM.

**Basic Type-Safe Operations:**
```dart
// Assuming you have a Drift database setup
final drift = DatabaseBridgeDriftService(myDatabase);

// Type-safe CRUD operations
final newUser = UsersCompanion(name: Value('John'), age: Value(30));
await drift.insert<UsersTable, User>(newUser);

final users = await drift.getAll<UsersTable, User>();
final adultUsers = await drift.getWithComplexFilter<UsersTable, User>([
  usersTable.age.isBiggerThanValue(18)
]);
```

**Reactive Queries:**
```dart
// Reactive streams for real-time UI updates
drift.watchAll<UsersTable, User>().listen((users) {
  // Update UI when data changes
  setState(() => userList = users);
});

// Filtered reactive queries
drift.watchFiltered<UsersTable, User>(
  (table) => table.age.isBiggerThanValue(21) & table.name.like('%John%')
).listen((filteredUsers) {
  print('Filtered users: ${filteredUsers.length}');
});
```

**Advanced Querying and Aggregations:**
```dart
// Complex filtering with multiple conditions
final complexUsers = await drift.getWithSorting<UsersTable, User>(
  [(table) => OrderingTerm.desc(table.age)],
  filter: (table) => table.age.isBetweenValues(20, 40)
);

// Pagination
final page1 = await drift.getPaged<UsersTable, User>(
  limit: 10,
  offset: 0,
  orderBy: [(table) => OrderingTerm.asc(table.name)]
);

// Aggregations
final totalUsers = await drift.count<UsersTable, User>();
final avgAge = await drift.avg<UsersTable, User>('age');
final ageStats = await drift.aggregateWithGroupBy<UsersTable, User>(
  groupByColumns: ['department'],
  aggregations: {'avg_age': 'AVG(age)', 'count': 'COUNT(*)'}
);
```

---

### ObjectBox (High-Performance NoSQL)

ACID-compliant object database with advanced querying capabilities and high-performance operations.

**Basic Object Operations:**
```dart
final objectBox = DatabaseBridgeObjectboxService();
await objectBox.initializeStore();

// Your entity classes would be annotated with @Entity
final user = User(name: 'John', age: 30); // Your ObjectBox entity

final userId = await objectBox.put(user);
final retrievedUser = await objectBox.get<User>(userId);
final allUsers = await objectBox.getAll<User>();
```

**Advanced Querying:**
```dart
// Query with conditions
final adults = await objectBox.query<User>(
  User_.age.greaterThan(18),
  orderBy: User_.name,
  limit: 50
);

final firstAdult = await objectBox.queryFirst<User>(
  User_.age.greaterThan(21) & User_.name.startsWith('J')
);

// Count with conditions
final adultCount = await objectBox.queryCount<User>(
  User_.age.greaterThan(18)
);
```

**Batch Operations and Transactions:**
```dart
// Batch operations
final userIds = await objectBox.putMany<User>([
  User(name: 'Alice', age: 25),
  User(name: 'Bob', age: 30),
  User(name: 'Charlie', age: 35)
]);

await objectBox.removeMany<User>([userIds[0], userIds[1]]);

// Transaction for atomic operations
await objectBox.runInTransaction(() {
  objectBox.put(User(name: 'Transaction User 1'));
  objectBox.put(User(name: 'Transaction User 2'));
  // If any operation fails, all are rolled back
});
```

---

### Secure Storage

Encrypted key-value storage for sensitive data using platform-specific secure storage solutions.

**Basic Secure Operations:**
```dart
final secure = DatabaseBridgeSecureStorageService();
await secure.initialize();

// Store sensitive data
await secure.write('api_key', 'your_secret_api_key');
await secure.write('auth_token', 'jwt_token_here');

// Batch write multiple values
await secure.writeBatch({
  'refresh_token': 'refresh_jwt',
  'user_id': '12345'
});

// Read data
final apiKey = await secure.read('api_key');
final allData = await secure.readAll();

// Check existence and cleanup
final hasApiKey = await secure.containsKey('api_key');
await secure.delete('api_key');
await secure.deleteAll();
```

---

## API Reference

### Classes

#### `DatabaseBridgeException`

Unified exception class for handling database errors across all services.

```dart
const DatabaseBridgeException({this.error});
```

**Properties**

| Property | Type | Description |
|----------|------|-------------|
| `error` | `dynamic` | The original error that caused this exception |

#### `JobDone`

Success confirmation class returned by operations that don't return meaningful data. This class serves as a semantic indicator that an operation completed successfully without providing specific return values.

```dart
const JobDone();
```

#### `DatabaseBridgeHiveService`

Service for Hive NoSQL database operations with optional encryption support.

```dart
factory DatabaseBridgeHiveService();
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `initializeDatabase()` | `Future<JobDone>` | Initialize the Hive database |
| `closeDatabase()` | `Future<JobDone>` | Close the database |
| `openBox(String boxName)` | `Future<Box<dynamic>>` | Open a Hive box |
| `closeBox(String boxName)` | `Future<JobDone>` | Close a specific box |
| `write(String boxName, String key, dynamic value)` | `Future<JobDone>` | Write a single key-value pair |
| `writeMultiple(String boxName, Map<dynamic, dynamic> entries)` | `Future<JobDone>` | Write multiple key-value pairs |
| `read(String boxName, String key, {dynamic defaultValue})` | `Future<dynamic>` | Read a value by key |
| `update(String boxName, String key, dynamic value)` | `Future<JobDone>` | Update an existing value |
| `addOrUpdate(String boxName, String key, dynamic value)` | `Future<JobDone>` | Add or update a value |
| `delete(String boxName, String key)` | `Future<JobDone>` | Delete a single key |
| `deleteMultiple(String boxName, Iterable<dynamic> keys)` | `Future<JobDone>` | Delete multiple keys |
| `clearBox(String boxName)` | `Future<int>` | Clear all data in a box |
| `deleteBoxFromDisk(String boxName)` | `Future<JobDone>` | Delete a box from disk |
| `deleteDatabaseFromDisk()` | `Future<JobDone>` | Delete the entire database |
| `hasProperty(String boxName, String key)` | `Future<bool>` | Check if a key exists |
| `registerAdapter<T>(TypeAdapter<T> adapter, {bool override})` | `Future<JobDone>` | Register a type adapter |

#### `DatabaseBridgeHiveSecurity`

Handles AES encryption key management for Hive using secure storage.

```dart
DatabaseBridgeHiveSecurity();
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `generateAndSaveSecureKeyIfNotExist()` | `Future<void>` | Generate and save encryption key if it doesn't exist |
| `readEncryptionCipher()` | `Future<HiveCipher>` | Read the encryption cipher for data encryption |
| `deleteSecureKey()` | `Future<void>` | Delete the stored encryption key |

#### `DatabaseBridgeSqfliteService`

Service for SQLite database operations via Sqflite with full SQL support.

```dart
factory DatabaseBridgeSqfliteService({
  required String databaseFileName,
  ConflictAlgorithm defaultConflictAlgorithm,
});
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `openSqliteDatabase({int databaseVersion, OnCreate onCreate, OnUpgrade onUpgrade, OnDowngrade onDowngrade, bool readOnly})` | `Future<JobDone>` | Open/create SQLite database |
| `closeSqliteDatabase()` | `Future<JobDone>` | Close the database |
| `deleteSqliteDatabase()` | `Future<JobDone>` | Delete the database file |
| `read(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset})` | `Future<List<Map<String, Object?>>>` | Query table data |
| `readFirst(String table, {...})` | `Future<Map<String, Object?>>` | Get first row from query |
| `insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm conflictAlgorithm})` | `Future<bool>` | Insert row (returns success) |
| `update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm})` | `Future<bool>` | Update rows (returns success) |
| `delete(String table, {String? where, List<Object?>? whereArgs})` | `Future<bool>` | Delete rows (returns success) |
| `rawQuery(String sql, [List<Object?>? arguments])` | `Future<List<Map<String, Object?>>>` | Execute raw SQL query |
| `rawInsert(String sql, [List<Object?>? arguments])` | `Future<int>` | Execute raw insert |
| `rawUpdate(String sql, [List<Object?>? arguments])` | `Future<int>` | Execute raw update |
| `rawDelete(String sql, [List<Object?>? arguments])` | `Future<int>` | Execute raw delete |
| `excuteRawQuery(String sql, [List<Object?>? arguments])` | `Future<JobDone>` | Execute raw query without return |
| `countRows(String table)` | `Future<int>` | Count all rows in table |
| `count(String table, {String? where, List<Object?>? whereArgs})` | `Future<int>` | Count rows with conditions |
| `sum(String table, String column, {String? where, List<Object?>? whereArgs})` | `Future<double?>` | Sum column values |
| `avg(String table, String column, {String? where, List<Object?>? whereArgs})` | `Future<double?>` | Average column values |
| `min(String table, String column, {String? where, List<Object?>? whereArgs})` | `Future<Object?>` | Minimum column value |
| `max(String table, String column, {String? where, List<Object?>? whereArgs})` | `Future<Object?>` | Maximum column value |
| `aggregateQuery(String table, {required List<String> groupBy, required Map<String, String> aggregations, String? where, List<Object?>? whereArgs, String? having, String? orderBy, int? limit, int? offset})` | `Future<List<Map<String, Object?>>>` | Complex aggregation queries |
| `transaction<T>(Future<T> Function(Transaction txn) action)` | `Future<T>` | Execute in transaction |
| `executeBatch(void Function(SqfliteBatch batch) operations, {bool? exclusive, bool? noResult, bool? continueOnError})` | `Future<List<Object?>>` | Execute batch operations |

#### `DatabaseBridgeDriftService`

Type-safe SQL service using Drift ORM with reactive capabilities.

```dart
factory DatabaseBridgeDriftService(GeneratedDatabase database);
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `getAll<T extends Table, D>()` | `Future<List<D>>` | Get all records |
| `getSingle<T extends Table, D>(Expression<bool> Function(T) filter)` | `Future<D?>` | Get single record |
| `insert<T extends Table, D>(Insertable<D> entity, {InsertMode mode, UpsertClause<T, D>? onConflict})` | `Future<int>` | Insert record |
| `update<T extends Table, D>(Insertable<D> entity)` | `Future<bool>` | Update record |
| `delete<T extends Table, D>(Expression<bool> Function(T) filter)` | `Future<int>` | Delete records |
| `closeDatabase()` | `Future<void>` | Close the database |
| `batchInsert<T extends Table, D>(List<Insertable<D>> entities, {InsertMode mode, UpsertClause<T, D>? onConflict})` | `Future<List<int>>` | Batch insert |
| `batchUpdate<T extends Table, D>(List<Insertable<D>> entities)` | `Future<List<bool>>` | Batch update |
| `batchDelete<T extends Table, D>(Expression<bool> Function(T) filter)` | `Future<int>` | Batch delete |
| `executeBatch(List<BatchOperation> operations)` | `Future<void>` | Execute batch operations |
| `watchAll<T extends Table, D>()` | `Stream<List<D>>` | Reactive stream of all records |
| `watchFiltered<T extends Table, D>(Expression<bool> Function(T) filter)` | `Stream<List<D>>` | Reactive filtered stream |
| `watchSingle<T extends Table, D>(Expression<bool> Function(T) filter)` | `Stream<D?>` | Reactive single record stream |
| `transaction<R>(Future<R> Function() action)` | `Future<R>` | Execute in transaction |
| `customSelect<T>(String query, {List<Variable<Object>>? variables})` | `Future<List<T>>` | Custom select query |
| `customUpdate(String query, {List<Variable<Object>>? variables})` | `Future<int>` | Custom update query |
| `customInsert(String query, {List<Variable<Object>>? variables})` | `Future<int>` | Custom insert query |
| `customStatement(String query, {List<Variable<Object>>? variables})` | `Future<void>` | Custom SQL statement |
| `getWithComplexFilter<T extends Table, D>(List<Expression<bool>> filters, {bool andLogic})` | `Future<List<D>>` | Complex filtering |
| `getIn<T extends Table, D>(Expression column, List<Object?> values)` | `Future<List<D>>` | IN clause queries |
| `getLike<T extends Table, D>(Expression<String> column, String pattern)` | `Future<List<D>>` | LIKE queries |
| `getFirstWhere<T extends Table, D>(List<Expression<bool>> conditions, {bool andLogic})` | `Future<D?>` | Get first matching record |
| `getWithSorting<T extends Table, D>(List<OrderingTerm Function(T)> orderBy, {Expression<bool> Function(T)? filter, int? limit, int? offset})` | `Future<List<D>>` | Sorted queries |
| `getPaged<T extends Table, D>({Expression<bool> Function(T)? filter, List<OrderClauseGenerator<T>>? orderBy, required int limit, required int offset})` | `Future<List<D>>` | Paginated queries |
| `getLimited<T extends Table, D>(int limit, {Expression<bool> Function(T)? filter, List<OrderClauseGenerator<T>>? orderBy})` | `Future<List<D>>` | Limited result queries |
| `getFirstSorted<T extends Table, D>(List<OrderingTerm Function(T)> orderBy, {Expression<bool> Function(T)? filter})` | `Future<D?>` | Get first sorted record |
| `count<T extends Table, D>({Expression<bool>? filter})` | `Future<int>` | Count records |
| `sum<T extends Table, D>(String columnName, {Expression<bool>? filter})` | `Future<double?>` | Sum column values |
| `avg<T extends Table, D>(String columnName, {Expression<bool>? filter})` | `Future<double?>` | Average column values |
| `min<T extends Table, D>(String columnName, {Expression<bool>? filter})` | `Future<Object?>` | Minimum column value |
| `max<T extends Table, D>(String columnName, {Expression<bool>? filter})` | `Future<Object?>` | Maximum column value |
| `aggregateWithGroupBy<T extends Table, D>({required List<String> groupByColumns, required Map<String, String> aggregations, Expression<bool>? filter, String? having})` | `Future<List<Map<String, Object?>>>` | Grouped aggregations |

#### `DatabaseBridgeObjectboxService`

High-performance NoSQL object database service.

```dart
factory DatabaseBridgeObjectboxService({
  Directory? storeDirectory,
  Future<Store> Function(String directory)? storeFactory,
});
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `initializeStore()` | `Future<JobDone>` | Initialize ObjectBox store |
| `closeStore()` | `Future<JobDone>` | Close the store |
| `get<T>(int id)` | `Future<T?>` | Get object by ID |
| `getAll<T>()` | `Future<List<T>>` | Get all objects |
| `put<T>(T object)` | `Future<int>` | Insert or update object |
| `putMany<T>(List<T> objects)` | `Future<List<int>>` | Batch insert/update |
| `remove<T>(int id)` | `Future<bool>` | Remove object by ID |
| `removeMany<T>(List<int> ids)` | `Future<int>` | Remove multiple objects |
| `removeAll<T>()` | `Future<int>` | Remove all objects |
| `contains<T>(int id)` | `Future<bool>` | Check if object exists |
| `count<T>()` | `Future<int>` | Count objects |
| `query<T>(Condition<T>? condition, {QueryProperty<T, dynamic>? orderBy, int? flags, int? offset, int? limit})` | `Future<List<T>>` | Query with conditions |
| `queryFirst<T>(Condition<T>? condition, {QueryProperty<T, dynamic>? orderBy, int? flags})` | `Future<T?>` | Get first query result |
| `queryCount<T>(Condition<T>? condition)` | `Future<int>` | Count query results |
| `runInTransaction<R>(R Function() action)` | `Future<R>` | Execute in transaction |
| `clearAllData()` | `Future<JobDone>` | Clear all data |
| `compact()` | `Future<JobDone>` | Compact database |
| `isStoreOpen()` | `bool` | Check if store is open |
| `store` | `Store?` | Direct access to ObjectBox store |

#### `DatabaseBridgeSecureStorageService`

Encrypted key-value storage service using platform secure storage.

```dart
factory DatabaseBridgeSecureStorageService();
```

**Methods**

| Method | Returns | Description |
|--------|---------|-------------|
| `initialize()` | `Future<JobDone>` | Initialize secure storage |
| `write(String key, String value)` | `Future<void>` | Write encrypted value |
| `writeBatch(Map<String, String> data)` | `Future<void>` | Write multiple encrypted values |
| `read(String key)` | `Future<String?>` | Read encrypted value |
| `containsKey(String key)` | `Future<bool>` | Check if key exists |
| `readAll()` | `Future<Map<String, String>>` | Read all encrypted data |
| `getKeys()` | `Future<List<String>>` | Get all keys |
| `delete(String key)` | `Future<void>` | Delete encrypted value |
| `deleteAll()` | `Future<void>` | Delete all encrypted data |

### Typedefs

#### `SqfliteBatch`

```dart
typedef SqfliteBatch = Batch;
```

Represents a Sqflite batch operation for grouping multiple database operations.

#### `OnCreate`

```dart
typedef OnCreate = FutureOr<void> Function(Database, int)?;
```

Callback function for database creation, receives the database instance and version.

#### `OnUpgrade`

```dart
typedef OnUpgrade = FutureOr<void> Function(Database, int, int)?;
```

Callback function for database upgrade, receives database, old version, and new version.

#### `OnDowngrade`

```dart
typedef OnDowngrade = FutureOr<void> Function(Database, int, int)?;
```

Callback function for database downgrade, receives database, old version, and new version.

#### `BatchOperation`

```dart
typedef BatchOperation = void Function(Batch batch);
```

Function type for Drift batch operations, receives a Batch instance to add operations to.

---

## Complete Examples

### Multi-Service Application

This example demonstrates using multiple database services in a single Flutter application.

**Note:** The examples assume you have defined the necessary entity classes (like `UserProfile`) with appropriate annotations for ObjectBox and Drift. The focus is on showing how to use the database bridge services together.

```dart
import 'package:database_bridge/database_bridge.dart';

class DataManager {
  late final DatabaseBridgeHiveService _hive;
  late final DatabaseBridgeSqfliteService _sqlite;
  late final DatabaseBridgeSecureStorageService _secure;
  late final DatabaseBridgeObjectboxService _objectBox;

  Future<void> initialize() async {
    // Initialize all services
    _hive = DatabaseBridgeHiveService();
    await _hive.initializeDatabase();

    _sqlite = DatabaseBridgeSqfliteService(databaseFileName: 'app_data.db');
    await _sqlite.openSqliteDatabase(
      databaseVersion: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_preferences (
            id INTEGER PRIMARY KEY,
            user_id TEXT UNIQUE,
            theme TEXT DEFAULT 'light',
            notifications_enabled INTEGER DEFAULT 1
          )
        ''');
      }
    );

    _secure = DatabaseBridgeSecureStorageService();
    await _secure.initialize();

    _objectBox = DatabaseBridgeObjectboxService();
    await _objectBox.initializeStore();
  }

  // Use Hive for app configuration
  Future<void> saveAppConfig(Map<String, dynamic> config) async {
    await _hive.write('config', 'app_settings', config);
  }

  // Use Sqflite for user preferences
  Future<void> saveUserPreferences(String userId, Map<String, dynamic> prefs) async {
    await _sqlite.insert('user_preferences', {
      'user_id': userId,
      'theme': prefs['theme'],
      'notifications_enabled': prefs['notifications'] ? 1 : 0,
    });
  }

  // Use Secure Storage for sensitive data
  Future<void> saveAuthToken(String token) async {
    await _secure.write('auth_token', token);
  }

  // Use ObjectBox for complex objects
  Future<void> saveUserProfile(UserProfile profile) async {
    await _objectBox.put(profile);
  }

  // Combined data retrieval
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final config = await _hive.read('config', 'app_settings');
    final prefs = await _sqlite.readFirst(
      'user_preferences',
      where: 'user_id = ?',
      whereArgs: [userId]
    );
    final token = await _secure.read('auth_token');
    final profile = await _objectBox.queryFirst<UserProfile>(
      UserProfile_.userId.equals(userId)
    );

    return {
      'config': config,
      'preferences': prefs,
      'hasAuthToken': token != null,
      'profile': profile,
    };
  }
}
```

### Transaction Management

Demonstrates comprehensive transaction handling across different database services.

```dart
import 'package:database_bridge/database_bridge.dart';

class TransactionExample {
  final DatabaseBridgeSqfliteService _sqlite;
  final DatabaseBridgeObjectboxService _objectBox;
  final DatabaseBridgeDriftService _drift;

  TransactionExample(this._sqlite, this._objectBox, this._drift);

  // Sqflite transaction with rollback capability
  Future<bool> transferFunds(String fromAccount, String toAccount, double amount) async {
    try {
      return await _sqlite.transaction((txn) async {
        // Check balance
        final fromBalance = await txn.rawQuery(
          'SELECT balance FROM accounts WHERE id = ?',
          [fromAccount]
        );

        if (fromBalance.isEmpty || fromBalance.first['balance'] < amount) {
          throw DatabaseBridgeException(error: 'Insufficient funds');
        }

        // Perform transfer
        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance - ? WHERE id = ?',
          [amount, fromAccount]
        );

        await txn.rawUpdate(
          'UPDATE accounts SET balance = balance + ? WHERE id = ?',
          [amount, toAccount]
        );

        // Log transaction
        await txn.rawInsert(
          'INSERT INTO transactions (from_account, to_account, amount, timestamp) VALUES (?, ?, ?, ?)',
          [fromAccount, toAccount, amount, DateTime.now().toIso8601String()]
        );

        return true;
      });
    } catch (e) {
      print('Transaction failed: $e');
      return false;
    }
  }

  // ObjectBox transaction for complex object operations
  Future<void> updateUserWithRelatedData(User user, List<Post> posts) async {
    await _objectBox.runInTransaction(() {
      // Update user
      _objectBox.put(user);

      // Update related posts
      for (final post in posts) {
        post.author.target = user; // Set relation
        _objectBox.put(post);
      }

      // Update user stats
      final userStats = UserStats(userId: user.id, postCount: posts.length);
      _objectBox.put(userStats);
    });
  }

  // Drift batch operations
  Future<void> bulkUserUpdate(List<UserUpdate> updates) async {
    await _drift.executeBatch(updates.map((update) {
      return (batch) {
        batch.update(
          _drift.usersTable,
          UsersCompanion(
            name: Value(update.newName),
            email: Value(update.newEmail),
          ),
          where: (table) => table.id.equals(update.userId)
        );
      };
    }).toList());
  }

  // Cross-service transaction simulation
  Future<bool> createUserAccount(User user, String initialPassword) async {
    try {
      // Store user profile in ObjectBox
      final userId = await _objectBox.put(user);

      // Store credentials securely
      await DatabaseBridgeSecureStorageService()
          .write('password_$userId', initialPassword);

      // Create user preferences in Sqflite
      await _sqlite.insert('user_preferences', {
        'user_id': user.id.toString(),
        'theme': 'light',
        'notifications_enabled': 1,
      });

      return true;
    } catch (e) {
      // Cleanup on failure
      await _objectBox.remove<User>(user.id);
      await DatabaseBridgeSecureStorageService().delete('password_${user.id}');
      await _sqlite.delete('user_preferences',
          where: 'user_id = ?', whereArgs: [user.id.toString()]);

      throw DatabaseBridgeException(error: 'Failed to create user account: $e');
    }
  }
}

// Supporting classes for the example
class UserUpdate {
  final int userId;
  final String newName;
  final String newEmail;

  UserUpdate(this.userId, this.newName, this.newEmail);
}
```

---

## License

```
MIT License

Copyright (c) 2026 Mustafa Fahimi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
Made with ❤️ by <a href="https://github.com/mustafa-fahimi">Mustafa Fahimi</a>
</p>
