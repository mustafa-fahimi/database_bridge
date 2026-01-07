## [1.0.0] - 2025-01-07

### Initial Release

- **Unified Database API**: Consistent interface across all supported databases
- **SQL Database Support**: Drift (type-safe with reactive streams) and Sqflite (raw SQL)
- **NoSQL Database Support**: Hive (with AES encryption) and ObjectBox (high-performance)
- **Secure Storage**: Flutter Secure Storage for sensitive data
- **Core Features**:
  - Transaction support for data integrity
  - Batch operations for multiple database actions
  - Comprehensive error handling with `DatabaseBridgeException`
  - Cross-platform support (iOS, Android, Web, Desktop)
  - Reactive streams for real-time data updates (Drift)
  - Raw SQL execution capabilities
  - Aggregation functions (count, sum, avg, min, max)
