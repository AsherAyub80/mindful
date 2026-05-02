class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  ApiException({required this.message, required this.statusCode, this.code});
  bool get isUnauthorized => statusCode == 401;
}
