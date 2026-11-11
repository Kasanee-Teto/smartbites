class HydrationReminder {
  const HydrationReminder({
    this.enabled = false,
    this.startMinute = 8 * 60,
    this.endMinute = 22 * 60,
    this.interval = const Duration(hours: 1),
    this.browser = true,
    this.sound = true,
    this.alarm = false,
    this.smart = true,
  });

  final bool enabled;
  final int startMinute;
  final int endMinute;
  final Duration interval;
  final bool browser;
  final bool sound;
  final bool alarm;
  final bool smart;

  bool isActiveAt(DateTime time) {
    final minute = time.hour * 60 + time.minute;
    if (startMinute == endMinute) return true;
    if (startMinute < endMinute) {
      return minute >= startMinute && minute < endMinute;
    }
    return minute >= startMinute || minute < endMinute;
  }

  bool isDue({
    required DateTime now,
    required DateTime anchor,
    required double score,
    required int goal,
    DateTime? snoozedUntil,
  }) {
    final due = snoozedUntil ?? anchor.add(interval);
    return enabled &&
        isActiveAt(now) &&
        (!smart || score < goal) &&
        !now.isBefore(due);
  }

  HydrationReminder copyWith({
    bool? enabled,
    int? startMinute,
    int? endMinute,
    Duration? interval,
    bool? browser,
    bool? sound,
    bool? alarm,
    bool? smart,
  }) => HydrationReminder(
    enabled: enabled ?? this.enabled,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    interval: interval ?? this.interval,
    browser: browser ?? this.browser,
    sound: sound ?? this.sound,
    alarm: alarm ?? this.alarm,
    smart: smart ?? this.smart,
  );
}
