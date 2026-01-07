# Database Bridge

[![pub package](https://img.shields.io/pub/v/database_bridge.svg)](https://pub.dev/packages/database_bridge)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A unified Flutter database service wrapper that provides a consistent API for various database solutions, including SQL databases (Drift, Sqflite), NoSQL databases (Hive, ObjectBox), and secure storage.

## Features

- **Unified API**: Consistent interface across all supported databases
- **Multiple Database Support**:
  - SQL: Drift, Sqflite
  - NoSQL: Hive, ObjectBox
  - Secure Storage: Flutter Secure Storage
- **Type Safety**: Strong typing with Dart's type system
- **Transaction Support**: Batch operations and transactions
- **Error Handling**: Comprehensive error handling with custom exceptions
- **Cross-Platform**: Works on iOS, Android, Web, and Desktop

## Supported Databases

| Database | Type | Use Case |
|----------|------|----------|
| **Drift** | SQL | Advanced SQL queries, migrations, reactive streams |
| **Sqflite** | SQL | SQLite database with raw SQL support |
| **Hive** | NoSQL | Fast key-value storage, encryption support |
| **ObjectBox** | NoSQL | High-performance object database |
| **Flutter Secure Storage** | Secure | Encrypted key-value storage for sensitive data |

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  database_bridge: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Hive Example

```dart
import 'package:database_bridge/database_bridge.dart';

// Create service instance
final hiveService = DatabaseBridgeHiveServiceImplementation();

// Initialize database
await hiveService.initializeDatabase();

// Write data
await hiveService.write('userBox', 'username', 'john_doe');

// Read data
final username = await hiveService.read('userBox', 'username');

// Close database
await hiveService.closeDatabase();
```

### Sqflite Example

```dart
import 'package:database_bridge/database_bridge.dart';

// Create service instance
final sqliteService = DatabaseBridgeSqfliteServiceImplementation();

// Open database
await sqliteService.openSqliteDatabase(
  databaseVersion: 1,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT
      )
    ''');
  },
);

// Insert data
await sqliteService.insert('users', {
  'name': 'John Doe',
  'email': 'john@example.com',
});

// Query data
final users = await sqliteService.read('users');

// Close database
await sqliteService.closeSqliteDatabase();
```

### Secure Storage Example

```dart
import 'package:database_bridge/database_bridge.dart';

// Create service instance
final secureService = DatabaseBridgeSecureStorageServiceImplementation();

// Write secure data
await secureService.write('auth_token', 'your_jwt_token');

// Read secure data
final token = await secureService.read('auth_token');
```

## API Overview

All services implement consistent interfaces with common operations:

### Common Operations
- `initializeDatabase()` / `openDatabase()` - Initialize database connection
- `closeDatabase()` - Close database connection
- `deleteDatabase()` - Delete database from disk

### CRUD Operations
- `write()` / `insert()` - Create/update data
- `read()` - Read data
- `update()` - Update existing data
- `delete()` - Delete data

### Advanced Features
- **Transactions**: Atomic operations across multiple statements
- **Batch Operations**: Multiple operations in a single transaction
- **Aggregations**: Sum, count, average, min/max functions (SQL databases)
- **Raw Queries**: Direct SQL execution (SQL databases)

## Error Handling

The package provides comprehensive error handling through `DatabaseBridgeException`:

```dart
try {
  await service.write('box', 'key', 'value');
} on DatabaseBridgeException catch (e) {
  print('Database error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Mostafa Fahimi**

---

For more detailed documentation and examples, visit the [pub.dev page](https://pub.dev/packages/database_bridge).
