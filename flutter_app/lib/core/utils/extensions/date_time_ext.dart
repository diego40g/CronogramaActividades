import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get formatted => DateFormat.yMMMd().format(this);

  String get formattedWithTime => DateFormat.yMMMd().add_jm().format(this);

  String get timeOnly => DateFormat.jm().format(this);

  String get dateOnly => DateFormat.yMd().format(this);

  String get dayOfWeek => DateFormat.EEEE().format(this);

  String get shortDayOfWeek => DateFormat.E().format(this);

  String get monthYear => DateFormat.yMMM().format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).startOfDay;
  }

  DateTime get endOfWeek {
    final diff = DateTime.sunday - weekday;
    return add(Duration(days: diff)).endOfDay;
  }

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int get minuteOfDay => hour * 60 + minute;

  DateTime copyWithTime({int? hour, int? minute, int? second}) {
    return DateTime(
      year,
      month,
      day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
    );
  }

  String get relativeDate {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';
    return formatted;
  }
}
