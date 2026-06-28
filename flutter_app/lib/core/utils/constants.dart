class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Cronograma Actividades';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';
  static const String subtasksCollection = 'subtasks';
  static const String tagsCollection = 'tags';
  static const String timeBlocksCollection = 'timeBlocks';

  // Hive Boxes
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String tasksBox = 'tasks_cache';

  // Shared Preferences Keys
  static const String themeKey = 'theme';
  static const String localeKey = 'locale';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastSyncKey = 'last_sync';

  // Task Limits
  static const int maxTaskTitleLength = 200;
  static const int maxTaskDescriptionLength = 2000;
  static const int maxSubtasks = 50;
  static const int maxTags = 10;

  // Time
  static const int minutesInDay = 1440;
  static const int defaultReminderMinutes = 15;

  // Pagination
  static const int defaultPageSize = 20;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration syncInterval = Duration(minutes: 5);
}
