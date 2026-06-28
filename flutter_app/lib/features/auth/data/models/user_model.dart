import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
    String? googleCalendarId,
    String? fcmToken,
    required UserSettingsModel settings,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      googleCalendarId: googleCalendarId,
      fcmToken: fcmToken,
      settings: settings.toEntity(),
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(AppUser entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoURL: entity.photoURL,
      googleCalendarId: entity.googleCalendarId,
      fcmToken: entity.fcmToken,
      settings: UserSettingsModel.fromEntity(entity.settings),
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

@freezed
abstract class UserSettingsModel with _$UserSettingsModel {
  const UserSettingsModel._();

  const factory UserSettingsModel({
    @Default('timeline') String defaultView,
    @Default('system') String theme,
    @Default('UTC') String timezone,
    @Default(false) bool syncWithGoogleCalendar,
    @Default(true) bool enableNotifications,
    @Default(15) int reminderMinutesBefore,
  }) = _UserSettingsModel;

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsModelFromJson(json);

  UserSettings toEntity() {
    return UserSettings(
      defaultView: DefaultView.values.firstWhere(
        (e) => e.name == defaultView,
        orElse: () => DefaultView.timeline,
      ),
      theme: AppThemeMode.values.firstWhere(
        (e) => e.name == theme,
        orElse: () => AppThemeMode.system,
      ),
      timezone: timezone,
      syncWithGoogleCalendar: syncWithGoogleCalendar,
      enableNotifications: enableNotifications,
      reminderMinutesBefore: reminderMinutesBefore,
    );
  }

  factory UserSettingsModel.fromEntity(UserSettings entity) {
    return UserSettingsModel(
      defaultView: entity.defaultView.name,
      theme: entity.theme.name,
      timezone: entity.timezone,
      syncWithGoogleCalendar: entity.syncWithGoogleCalendar,
      enableNotifications: entity.enableNotifications,
      reminderMinutesBefore: entity.reminderMinutesBefore,
    );
  }
}

DateTime _timestampToDateTime(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is DateTime) return timestamp;
  return DateTime.now();
}

dynamic _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
