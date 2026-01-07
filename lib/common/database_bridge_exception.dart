class DatabaseBridgeException implements Exception {
  const DatabaseBridgeException({this.error});

  final dynamic error;

  @override
  String toString() => 'DatabaseBridgeException: $error';
}
