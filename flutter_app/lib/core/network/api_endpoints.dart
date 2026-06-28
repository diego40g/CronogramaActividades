class ApiEndpoints {
  ApiEndpoints._();

  // Google Calendar API
  static const String googleCalendarBase =
      'https://www.googleapis.com/calendar/v3';
  static const String googleCalendarEvents = '$googleCalendarBase/calendars';

  // Helper to get calendar events endpoint
  static String calendarEvents(String calendarId) =>
      '$googleCalendarEvents/$calendarId/events';

  static String calendarEvent(String calendarId, String eventId) =>
      '$googleCalendarEvents/$calendarId/events/$eventId';
}
