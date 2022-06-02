// seconds
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

int daysFrom(int? fromTime, int? endTime) {
  int misOfADay = 24 * 60 * 60;
  int fromDays = (fromTime ?? 0) ~/ misOfADay;
  int endDays = (endTime ?? 0) ~/ misOfADay;
  return endDays - fromDays;
}

// seconds
int daysFromNow(int? fromTime) {
  return daysFrom(fromTime, DateTime.now().millisecondsSinceEpoch ~/ 1000);
}

bool isToday(int? fromTime) {
  return daysFromNow(fromTime) == 0;
}

extension DateTimeExt on DateTime {
  int get secondsSinceEpoch {
    return millisecondsSinceEpoch ~/ 1000;
  }

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  int get secondsOfDay => 60 * 60 * hour + 60 * minute + second;

  String formatString([String? pattern, String? locale]) =>
      DateFormat(pattern, locale).format(this);

  DateTime replaceTimeOfDay(TimeOfDay timeOfDay) {
    int interval = secondsSinceEpoch;
    interval -= secondsOfDay;
    interval += timeOfDay.timeOfSeconds;
    return DateTime.fromMillisecondsSinceEpoch(1000 * interval);
  }

  static DateTime fromSeconds(int? seconds) =>
      DateTime.fromMillisecondsSinceEpoch(1000 * (seconds ?? 0));
}

extension TimeOfDayExt on TimeOfDay {
  Duration get duration => Duration(hours: hour, minutes: minute);

  int get timeOfSeconds => 60 * 60 * hour + 60 * minute;
}

extension DateTimeSeconds on int {
  String formatDateString([String? pattern, String? locale]) =>
      DateFormat(pattern, locale).format(secondsToDate);

  DateTime get secondsToDate =>
      DateTime.fromMillisecondsSinceEpoch(1000 * this);
}

extension DateTimeString on String {
  DateTime formatDate([String? pattern, String? locale]) =>
      DateFormat(pattern, locale).parse(this);
}
