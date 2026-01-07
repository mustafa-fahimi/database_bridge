class DBSWException implements Exception {
  const DBSWException({this.error});

  final dynamic error;

  @override
  String toString() => 'DatabaseServiceException: $error';
}
