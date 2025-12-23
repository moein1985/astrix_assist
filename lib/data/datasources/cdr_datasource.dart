// DEPRECATED: This file is deprecated and will be removed.
// Use ssh_cdr_datasource.dart instead.

import '../models/cdr_model.dart';

class CdrDataSource {
  final String host;
  final int port;
  final String user;
  final String password;
  final String db;

  CdrDataSource({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.db,
  });

  Future<List<CdrModel>> getCdrRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? src,
    String? dst,
    String? disposition,
    int limit = 100,
  }) async {
    // DEPRECATED: MySQL connection removed
    // This method will throw an error
    throw UnimplementedError(
      'MySQL CDR datasource is deprecated. Use SshCdrDataSource instead.'
    );
  }
}
