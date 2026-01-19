import 'dart:convert';

class User {
  final String name;
  final String email;
  final String mobile;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
  });

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
    };
  }

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      password: json['password'] as String,
    );
  }

  // Convert User to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create User from JSON string
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }
}
