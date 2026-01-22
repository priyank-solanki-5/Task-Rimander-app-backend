import 'user.dart';

/// Generic API Response Wrapper
/// 
/// This class provides a standardized wrapper for API responses.
/// It encapsulates success status, messages, data, and errors in a consistent format.
/// 
/// Type Parameters:
/// - [T]: The type of data contained in the response
/// 
/// Example:
/// ```dart
/// final response = ApiResponse<User>(
///   success: true,
///   message: 'User retrieved successfully',
///   data: user,
/// );
/// ```
class ApiResponse<T> {
  /// Whether the API request was successful
  final bool success;
  
  /// Optional message from the server (success or error message)
  final String? message;
  
  /// The response data (type T)
  final T? data;
  
  /// Error details if the request failed
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
    };
  }
}

/// Login Response Model
/// 
/// Represents the response from a successful login request.
/// Contains the JWT authentication token and user information.
class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Registration Response Model
/// 
/// Represents the response from a successful user registration request.
class RegisterResponse {
  final String message;

  RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String,
    );
  }
}
