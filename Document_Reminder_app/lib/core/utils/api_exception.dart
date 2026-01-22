/// Base Exception for All API-Related Errors
/// 
/// This is the parent class for all custom API exceptions.
/// It provides a consistent structure for error handling across the application.
/// 
/// Properties:
/// - [message]: Human-readable error message
/// - [statusCode]: HTTP status code (if applicable)
/// - [error]: Additional error details
class ApiException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// HTTP status code (null for non-HTTP errors)
  final int? statusCode;
  
  /// Additional error details (e.g., validation errors)
  final dynamic error;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Network Connectivity Exception
/// 
/// Thrown when there is no internet connection or network connectivity issues.
/// This helps distinguish network problems from server errors.
/// 
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/api/tasks');
/// } on NetworkException catch (e) {
///   showSnackbar('Please check your internet connection');
/// }
/// ```
class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection. Please check your network.',
          statusCode: null,
        );
}

/// Unauthorized Exception (HTTP 401)
/// 
/// Thrown when the user is not authenticated or the JWT token is invalid/expired.
/// The app should typically redirect to the login screen when this occurs.
/// 
/// Example:
/// ```dart
/// try {
///   await apiClient.get('/api/profile');
/// } on UnauthorizedException {
///   // Redirect to login
///   Navigator.pushReplacementNamed(context, '/login');
/// }
/// ```
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized. Please login again.',
          statusCode: 401,
        );
}

/// Forbidden Exception (HTTP 403)
/// 
/// Thrown when the user is authenticated but doesn't have permission to access the resource.
/// This is different from 401 - the user is logged in but lacks the required permissions.
class ForbiddenException extends ApiException {
  ForbiddenException({String? message})
      : super(
          message: message ?? 'Access forbidden.',
          statusCode: 403,
        );
}

/// Not Found Exception (HTTP 404)
/// 
/// Thrown when the requested resource doesn't exist on the server.
/// This could be a task, document, category, or any other resource.
class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found.',
          statusCode: 404,
        );
}

/// Validation Exception (HTTP 400)
/// 
/// Thrown when the request data fails validation on the server.
/// Contains detailed validation errors for each field.
/// 
/// Example:
/// ```dart
/// try {
///   await authService.register(...);
/// } on ValidationException catch (e) {
///   final errors = e.validationErrors;
///   // Display field-specific errors to user
/// }
/// ```
class ValidationException extends ApiException {
  /// Map of field names to validation error messages
  final Map<String, dynamic>? validationErrors;

  ValidationException({
    String? message,
    this.validationErrors,
  }) : super(
          message: message ?? 'Validation failed.',
          statusCode: 400,
          error: validationErrors,
        );
}

/// Server Exception (HTTP 500, 502, 503, 504)
/// 
/// Thrown when the server encounters an internal error.
/// This indicates a problem on the backend that the client cannot fix.
/// Users should be advised to try again later.
class ServerException extends ApiException {
  ServerException({String? message})
      : super(
          message: message ?? 'Server error. Please try again later.',
          statusCode: 500,
        );
}

/// Timeout Exception (HTTP 408)
/// 
/// Thrown when a request takes too long to complete.
/// This could be due to slow network, server overload, or large data transfers.
class TimeoutException extends ApiException {
  TimeoutException({String? message})
      : super(
          message: message ?? 'Request timeout. Please try again.',
          statusCode: 408,
        );
}

/// Rate Limit Exception (HTTP 429)
/// 
/// Thrown when too many requests are made in a short period.
/// The user should wait before making more requests.
/// 
/// Example:
/// ```dart
/// try {
///   await apiClient.post('/api/tasks', data: taskData);
/// } on RateLimitException {
///   showSnackbar('Too many requests. Please wait a moment.');
/// }
/// ```
class RateLimitException extends ApiException {
  RateLimitException({String? message})
      : super(
          message: message ?? 'Too many requests. Please try again later.',
          statusCode: 429,
        );
}
