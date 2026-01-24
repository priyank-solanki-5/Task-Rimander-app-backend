class User {
  final String? id;
  final String username;
  final String email;
  final String mobilenumber;
  final String?
  password; // Only used for registration/login, not stored locally
  final NotificationPreferences? notificationPreferences;
  final UserSettings? settings;
  final Map<String, dynamic>? metadata;
  final DateTime? lastLogin;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.mobilenumber,
    this.password,
    this.notificationPreferences,
    this.settings,
    this.metadata,
    this.lastLogin,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create User from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['_id'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      mobilenumber: json['mobilenumber'] as String,
      notificationPreferences: json['notificationPreferences'] != null
          ? NotificationPreferences.fromJson(
              json['notificationPreferences'] as Map<String, dynamic>,
            )
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert User to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'username': username,
      'email': email,
      'mobilenumber': mobilenumber,
      if (password != null) 'password': password,
      if (notificationPreferences != null)
        'notificationPreferences': notificationPreferences!.toJson(),
      if (settings != null) 'settings': settings!.toJson(),
      if (metadata != null) 'metadata': metadata,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? mobilenumber,
    String? password,
    NotificationPreferences? notificationPreferences,
    UserSettings? settings,
    Map<String, dynamic>? metadata,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      mobilenumber: mobilenumber ?? this.mobilenumber,
      password: password ?? this.password,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationPreferences {
  final bool email;
  final bool push;
  final bool sms;
  final bool inApp;
  final int remindersBefore;
  final bool overdueNotifications;
  final bool completionNotifications;
  final bool recurringNotifications;

  NotificationPreferences({
    this.email = true,
    this.push = true,
    this.sms = false,
    this.inApp = true,
    this.remindersBefore = 1,
    this.overdueNotifications = true,
    this.completionNotifications = true,
    this.recurringNotifications = true,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      email: json['email'] as bool? ?? true,
      push: json['push'] as bool? ?? true,
      sms: json['sms'] as bool? ?? false,
      inApp: json['inApp'] as bool? ?? true,
      remindersBefore: json['remindersBefore'] as int? ?? 1,
      overdueNotifications: json['overdueNotifications'] as bool? ?? true,
      completionNotifications: json['completionNotifications'] as bool? ?? true,
      recurringNotifications: json['recurringNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'push': push,
      'sms': sms,
      'inApp': inApp,
      'remindersBefore': remindersBefore,
      'overdueNotifications': overdueNotifications,
      'completionNotifications': completionNotifications,
      'recurringNotifications': recurringNotifications,
    };
  }

  NotificationPreferences copyWith({
    bool? email,
    bool? push,
    bool? sms,
    bool? inApp,
    int? remindersBefore,
    bool? overdueNotifications,
    bool? completionNotifications,
    bool? recurringNotifications,
  }) {
    return NotificationPreferences(
      email: email ?? this.email,
      push: push ?? this.push,
      sms: sms ?? this.sms,
      inApp: inApp ?? this.inApp,
      remindersBefore: remindersBefore ?? this.remindersBefore,
      overdueNotifications: overdueNotifications ?? this.overdueNotifications,
      completionNotifications:
          completionNotifications ?? this.completionNotifications,
      recurringNotifications:
          recurringNotifications ?? this.recurringNotifications,
    );
  }
}

class UserSettings {
  final String theme;
  final String language;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String weekStartsOn;

  UserSettings({
    this.theme = 'light',
    this.language = 'en',
    this.timezone = 'UTC',
    this.dateFormat = 'YYYY-MM-DD',
    this.timeFormat = '24h',
    this.weekStartsOn = 'monday',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: json['theme'] as String? ?? 'light',
      language: json['language'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      dateFormat: json['dateFormat'] as String? ?? 'YYYY-MM-DD',
      timeFormat: json['timeFormat'] as String? ?? '24h',
      weekStartsOn: json['weekStartsOn'] as String? ?? 'monday',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'timezone': timezone,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'weekStartsOn': weekStartsOn,
    };
  }
}
