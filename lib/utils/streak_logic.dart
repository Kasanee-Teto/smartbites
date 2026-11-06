// Owner: Louis | FR: FR-36, FR-40 (Addition to PRD 9.1)

import 'package:budget_bites/models/daily_log.dart';

/// Representasi kemajuan menuju badge pencapaian streak berikutnya.
typedef StreakProgress = ({int target, int progress});

/// Menentukan apakah [DailyLog] memiliki setidaknya satu aktivitas yang tercatat
/// (asupan air minum > 0, menu makan selesai disantap, makanan terbuang, atau nihil sampah).
bool hasActivity(DailyLog log) {
  return log.waterMl > 0 ||
      log.mealsEaten.isNotEmpty ||
      log.wasteLogged ||
      log.noWasteMarked;
}

/// Menghitung jumlah hari beruntun (streak) aktivitas pengguna.
///
/// Aturan perhitungan:
/// - Menggunakan perbandingan tanggal saja (tahun, bulan, tanggal).
/// - Mengabaikan tanggal di masa depan (isAfter(today)).
/// - Streak berakhir pada [today] jika hari ini terdapat aktivitas.
/// - Jika hari ini belum ada aktivitas, streak tetap hidup berakhir pada kemarin.
/// - Celah 1 hari tanpa aktivitas (gap) mereset hitungan streak.
int calculateStreak(List<DailyLog> logs, DateTime today) {
  final normalizedToday = DateTime(today.year, today.month, today.day);

  // Kumpulkan tanggal-tanggal unik yang memiliki aktivitas dan tidak di masa depan.
  final activeDays = <DateTime>{};
  for (final log in logs) {
    final logDate = DateTime(log.date.year, log.date.month, log.date.day);
    if (logDate.isAfter(normalizedToday)) {
      continue;
    }
    if (hasActivity(log)) {
      activeDays.add(logDate);
    }
  }

  if (activeDays.isEmpty) {
    return 0;
  }

  final todayHasActivity = activeDays.contains(normalizedToday);
  final yesterday = DateTime(
    normalizedToday.year,
    normalizedToday.month,
    normalizedToday.day - 1,
  );
  final yesterdayHasActivity = activeDays.contains(yesterday);

  DateTime currentCheck;
  if (todayHasActivity) {
    currentCheck = normalizedToday;
  } else if (yesterdayHasActivity) {
    currentCheck = yesterday;
  } else {
    return 0;
  }

  var streak = 0;
  while (activeDays.contains(currentCheck)) {
    streak++;
    currentCheck = DateTime(
      currentCheck.year,
      currentCheck.month,
      currentCheck.day - 1,
    );
  }

  return streak;
}

/// Menghitung level gamifikasi streak berdasarkan ambang batas lencana PRD:
/// - Level 1: 0 s/d 2 hari
/// - Level 2: 3 s/d 6 hari (ambang badge 3-Day Streak)
/// - Level 3: 7 hari ke atas (ambang badge 7-Day Streak)
int streakLevel(int streak) {
  if (streak >= 7) return 3;
  if (streak >= 3) return 2;
  return 1;
}

/// Menghitung target lencana streak berikutnya beserta progres saat ini:
/// - Jika streak < 3: target berikutnya adalah 3 hari (lencana 3-Day Streak).
/// - Jika streak >= 3: target berikutnya adalah 7 hari (lencana 7-Day Streak).
StreakProgress nextBadgeProgress(int streak) {
  final safeStreak = streak < 0 ? 0 : streak;
  if (safeStreak < 3) {
    return (target: 3, progress: safeStreak);
  }
  return (target: 7, progress: safeStreak.clamp(0, 7));
}
