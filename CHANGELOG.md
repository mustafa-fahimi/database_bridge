# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-08

### Changed
- Updated README with comprehensive documentation and usage examples

## [1.0.0] - 2025-01-07

### Added
- Initial stable release
- Added unified database API with consistent interface across all supported databases
- Added SQL database support with Drift (type-safe with reactive streams) and Sqflite (raw SQL)
- Added NoSQL database support with Hive (AES encryption) and ObjectBox (high-performance)
- Added secure storage integration with Flutter Secure Storage for sensitive data
- Added transaction support for data integrity across all database types
- Added batch operations for multiple database actions
- Added comprehensive error handling with `DatabaseBridgeException`
- Added cross-platform support (iOS, Android, Web, Desktop)
- Added reactive streams for real-time data updates (Drift)
- Added raw SQL execution capabilities
- Added aggregation functions (count, sum, avg, min, max)
