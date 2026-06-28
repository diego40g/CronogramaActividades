import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? googleCalendarId;
  final String? fcmToken;
  final UserSettings settings;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.googleCalendarId,
    this.fcmToken,
    required this.settings,
    required this.createdAt,
  });

  bool get hasGoogleCalendar => googleCalendarId != null;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? googleCalendarId,
    String? fcmToken,
    UserSettings? settings,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      googleCalendarId: googleCalendarId ?? this.googleCalendarId,
      fcmToken: fcmToken ?? this.fcmToken,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        googleCalendarId,
        fcmToken,
        settings,
        createdAt,
      ];
}

enum DefaultView { timeline, calendar }
enum AppThemeMode { light, dark, system }

class UserSettings extends Equatable {
  final DefaultView defaultView;
  final AppThemeMode theme;
  final String timezone;
  final bool syncWithGoogleCalendar;
  final bool enableNotifications;
  final int reminderMinutesBefore;

  const UserSettings({
    this.defaultView = DefaultView.timeline,
    this.theme = AppThemeMode.system,
    this.timezone = 'UTC',
    this.syncWithGoogleCalendar = false,
    this.enableNotifications = true,
    this.reminderMinutesBefore = 15,
  });

  UserSettings copyWith({
    DefaultView? defaultView,
    AppThemeMode? theme,
    String? timezone,
    bool? syncWithGoogleCalendar,
    bool? enableNotifications,
    int? reminderMinutesBefore,
  }) {
    return UserSettings(
      defaultView: defaultView ?? this.defaultView,
      theme: theme ?? this.theme,
      timezone: timezone ?? this.timezone,
      syncWithGoogleCalendar: syncWithGoogleCalendar ?? this.syncWithGoogleCalendar,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }

  @override
  List<Object> get props => [
        defaultView,
        theme,
        timezone,
        syncWithGoogleCalendar,
        enableNotifications,
        reminderMinutesBefore,
      ];
}
