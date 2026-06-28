class Validators {
  Validators._();

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.length < minLength) {
      final field = fieldName ?? 'This field';
      return '$field must be at least $minLength characters';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      final field = fieldName ?? 'This field';
      return '$field must be at most $maxLength characters';
    }
    return null;
  }

  static String? taskTitle(String? value) {
    final requiredError = required(value, fieldName: 'Title');
    if (requiredError != null) return requiredError;

    final maxError = maxLength(value, 200, fieldName: 'Title');
    if (maxError != null) return maxError;

    return null;
  }

  static String? taskDescription(String? value) {
    if (value == null || value.isEmpty) return null;
    return maxLength(value, 2000, fieldName: 'Description');
  }

  static String? dateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) {
      return 'End time must be after start time';
    }
    return null;
  }

  static String? futureDate(DateTime? value, {bool allowToday = true}) {
    if (value == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final valueDate = DateTime(value.year, value.month, value.day);

    if (allowToday) {
      if (valueDate.isBefore(today)) {
        return 'Date must be today or in the future';
      }
    } else {
      if (valueDate.isBefore(today) || valueDate.isAtSameMomentAs(today)) {
        return 'Date must be in the future';
      }
    }
    return null;
  }

  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

typedef FormFieldValidator<T> = String? Function(T? value);
