class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  final bool isTimeout;
  final bool isNetworkError;

  ApiException(
    this.message, {
    this.statusCode,
    this.body,
    this.isTimeout = false,
    this.isNetworkError = false,
  });

  @override
  String toString() {
    String result = 'ApiException: $message';
    if (statusCode != null) {
      result += ' (Status code: $statusCode)';
    }
    if (isTimeout) {
      result += ' - Connection timed out';
    }
    if (isNetworkError) {
      result += ' - Network error';
    }
    return result;
  }
}
