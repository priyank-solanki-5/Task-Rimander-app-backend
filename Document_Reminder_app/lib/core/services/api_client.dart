import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../utils/api_exception.dart';
import 'token_storage.dart';

/// API Client - Singleton HTTP Client for Backend Communication
///
/// This class provides a centralized HTTP client using the Dio package.
/// It implements the Singleton pattern to ensure only one instance exists throughout the app.
///
/// Key Features:
/// - Singleton pattern for consistent configuration
/// - Automatic JWT token injection via interceptors
/// - Request/response logging in debug mode
/// - Automatic error handling and conversion to custom exceptions
/// - Support for file uploads and downloads with progress tracking
/// - Configurable timeouts and headers
///
/// Usage:
/// ```dart
/// final apiClient = ApiClient();
/// final response = await apiClient.get('/api/tasks');
/// ```
class ApiClient {
  /// Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  /// Factory constructor returns the singleton instance
  factory ApiClient() => _instance;

  /// Dio instance for making HTTP requests
  late Dio _dio;

  /// Private constructor - initializes Dio with base configuration and interceptors
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order:
    // 1. Auth interceptor - adds JWT token to requests
    _dio.interceptors.add(_AuthInterceptor());
    // 2. Logging interceptor - logs requests/responses in debug mode
    _dio.interceptors.add(_LoggingInterceptor());
    // 3. Error interceptor - converts Dio errors to custom exceptions
    _dio.interceptors.add(_ErrorInterceptor());
  }

  /// Getter to access the underlying Dio instance
  /// Useful for advanced use cases requiring direct Dio access
  Dio get dio => _dio;

  // ========================================
  // 🌐 HTTP REQUEST METHODS
  // ========================================

  /// Performs a GET request to fetch data from the server
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/tasks')
  /// - [queryParameters]: Optional query parameters (e.g., {'status': 'pending'})
  /// - [options]: Optional Dio request options for customization
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a POST request to create new resources on the server
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/tasks')
  /// - [data]: The request body data (will be JSON encoded)
  /// - [queryParameters]: Optional query parameters
  /// - [options]: Optional Dio request options
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a PUT request to update existing resources on the server
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/tasks/123')
  /// - [data]: The request body data (will be JSON encoded)
  /// - [queryParameters]: Optional query parameters
  /// - [options]: Optional Dio request options
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a PATCH request to partially update resources on the server
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/tasks/123/complete')
  /// - [data]: The request body data (will be JSON encoded)
  /// - [queryParameters]: Optional query parameters
  /// - [options]: Optional Dio request options
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Performs a DELETE request to remove resources from the server
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/tasks/123')
  /// - [data]: Optional request body data
  /// - [queryParameters]: Optional query parameters
  /// - [options]: Optional Dio request options
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads a file to the server using multipart/form-data
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/documents/upload')
  /// - [filePath]: Local file path to upload
  /// - [fieldName]: Form field name for the file (e.g., 'document')
  /// - [data]: Optional additional form data
  /// - [onSendProgress]: Optional callback for upload progress tracking
  ///
  /// Returns: Dio Response object containing the server response
  /// Throws: ApiException or its subclasses on error
  Future<Response> uploadFile(
    String path,
    String? filePath,
    String fieldName, {
    List<int>? fileBytes,
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      MultipartFile multipartFile;

      if (fileBytes != null) {
        // Use bytes (Works on Web & Mobile/Desktop)
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName ?? 'document',
        );
      } else if (filePath != null) {
        // Fallback to file path (Mobile/Desktop only)
        final file = File(filePath);
        multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      } else {
        throw ApiException(message: 'No file data provided');
      }

      final formData = FormData.fromMap({
        fieldName: multipartFile,
        if (data != null) ...data,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Downloads a file from the server to local storage
  ///
  /// Parameters:
  /// - [path]: The endpoint path (e.g., '/api/documents/123/download')
  /// - [savePath]: Local path where the file will be saved
  /// - [onReceiveProgress]: Optional callback for download progress tracking
  ///
  /// Returns: Dio Response object
  /// Throws: ApiException or its subclasses on error
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ========================================
// 🔐 AUTHENTICATION INTERCEPTOR
// ========================================

/// Interceptor that automatically adds JWT authentication token to requests
///
/// This interceptor retrieves the stored JWT token from secure storage
/// and adds it to the Authorization header of every outgoing request.
/// If no token is found, the request proceeds without authentication.
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Retrieve JWT token from secure storage
    final token = await TokenStorage.getToken();

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request
    handler.next(options);
  }
}

// ========================================
// 📝 LOGGING INTERCEPTOR
// ========================================

/// Interceptor for logging HTTP requests and responses in debug mode
///
/// This interceptor logs:
/// - Outgoing requests (method, URL, headers, body)
/// - Incoming responses (status code, data)
/// - Errors (status code, error message, response data)
///
/// Logging only occurs in debug mode to avoid performance impact in production.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint('│ REQUEST: ${options.method} ${options.uri}');
      debugPrint('│ Headers: ${options.headers}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint(
        '│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
      );
      debugPrint('│ Data: ${response.data}');
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────────────');
      debugPrint(
        '│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}',
      );
      debugPrint('│ Status: ${err.response?.statusCode}');
      debugPrint('│ Message: ${err.message}');
      debugPrint('│ Response: ${err.response?.data}');
      debugPrint('└─────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}

// ========================================
// ❌ ERROR HANDLING INTERCEPTOR
// ========================================

/// Interceptor that converts Dio errors into custom ApiException types
///
/// This interceptor intercepts all HTTP errors and converts them into
/// appropriate custom exception types based on:
/// - Error type (timeout, network, bad response, etc.)
/// - HTTP status code (400, 401, 403, 404, 429, 500, etc.)
///
/// Custom exceptions provide better error handling and user-friendly messages.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException exception;

    // Convert Dio exception types to custom exceptions
    switch (err.type) {
      // Timeout errors
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException();
        break;

      // Network connectivity errors
      case DioExceptionType.connectionError:
        exception = NetworkException();
        break;

      // HTTP response errors (4xx, 5xx)
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractErrorMessage(err.response?.data);

        // Map status codes to specific exception types
        switch (statusCode) {
          case 400: // Bad Request / Validation Error
            exception = ValidationException(
              message: message,
              validationErrors: err.response?.data,
            );
            break;
          case 401: // Unauthorized
            exception = UnauthorizedException(message: message);
            break;
          case 403: // Forbidden
            exception = ForbiddenException(message: message);
            break;
          case 404: // Not Found
            exception = NotFoundException(message: message);
            break;
          case 429: // Too Many Requests
            exception = RateLimitException(message: message);
            break;
          case 500: // Internal Server Error
          case 502: // Bad Gateway
          case 503: // Service Unavailable
          case 504: // Gateway Timeout
            exception = ServerException(message: message);
            break;
          default:
            exception = ApiException(
              message: message ?? 'An error occurred',
              statusCode: statusCode,
            );
        }
        break;

      // Request cancelled
      case DioExceptionType.cancel:
        exception = ApiException(
          message: 'Request cancelled',
          statusCode: null,
        );
        break;

      // Other unexpected errors
      default:
        exception = ApiException(
          message: err.message ?? 'An unexpected error occurred',
          statusCode: null,
        );
    }

    // Reject with the custom exception wrapped in DioException
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }

  /// Extracts error message from various response data formats
  ///
  /// The backend may return errors in different formats:
  /// - JSON object with 'message', 'error', or 'msg' field
  /// - Plain string
  ///
  /// Returns: Extracted error message or null
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }
}
