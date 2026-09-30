# SmartBites (budget_bites)

SmartBites adalah aplikasi mobile front-end (Flutter) perencana makan sehat, hemat budget, dan minim food waste. Proyek ini dikembangkan untuk mata kuliah Pemrograman Mobile Front-End (UTS Minggu 8). Aplikasi ini mengusung SDG 3 (Good Health and Well-Being) dan SDG 12.3 (Pengurangan Food Waste) dengan antarmuka Material Design 3, state terpusat via `setState()`, serta data mock lokal tanpa ketergantungan server.

## Setup & Menjalankan Proyek

1. Pastikan Flutter SDK telah terpasang di sistem.
2. Unduh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan analisis kode statis:
   ```bash
   flutter analyze
   ```
4. Jalankan aplikasi pada emulator atau perangkat:
   ```bash
   flutter run
   ```

## Aturan Git & Kolaborasi Tim

- **One Branch per Member:** Setiap anggota mengerjakan tugas pada Git branch masing-masing (`feature/louis`, `feature/jesseca`, `feature/gilbert`, `feature/edbert`).
- **Pull Request:** Penggabungan ke `main` hanya melalui Pull Request (PR) setelah `flutter analyze` bersih (0 issues) dan telah diuji pada emulator HP (compact) dan Tablet (medium/expanded).
- **No Direct Commit to Main:** Jangan melakukan commit langsung ke branch `main`.

## Struktur Folder & Pembagian Tugas (Ownership)

| File / Modul | Pemilik (Owner) | Cakupan FR |
|---|---|---|
| `lib/main.dart` | Louis | FR-01..03 |
| `lib/app.dart` | Louis | FR-01, FR-03 |
| `lib/theme/app_theme.dart` | Louis | FR-03 |
| `lib/utils/app_colors.dart` | Louis | FR-03 |
| `lib/utils/app_constants.dart` | Louis | FR-04, FR-22, FR-26 |
| `lib/utils/responsive_breakpoints.dart` | Louis | FR-02 |
| `lib/models/daily_log.dart` | Louis | FR-05, FR-36, FR-40 |
| `lib/screens/welcome_screen.dart` | Louis | FR-01 |
| `lib/screens/onboarding_screen.dart` | Louis | FR-01 |
| `lib/screens/home_screen.dart` | Louis | FR-04..06, FR-36 |
| `lib/widgets/app_logo.dart` | Louis | FR-01 |
| `lib/widgets/budget_card.dart` | Louis | FR-04 |
| `lib/widgets/section_title.dart` | Louis | FR-04, FR-05 |
| `lib/widgets/main_navigation.dart` | Louis | FR-02, FR-29, FR-30 |
| `lib/widgets/responsive_layout.dart` | Louis | FR-02 |
| `lib/widgets/quick_log_sheet.dart` | Louis | FR-30 |
| `lib/widgets/streak_card.dart` | Louis | FR-36, FR-40 |
| `lib/models/meal.dart` | Jesseca | FR-08, FR-09, FR-11, FR-12 |
| `lib/screens/meal_plan_screen.dart` | Jesseca | FR-08..10, FR-13 |
| `lib/screens/meal_detail_screen.dart` | Jesseca | FR-11, FR-12 |
| `lib/widgets/meal_card.dart` | Jesseca | FR-08, FR-11, FR-12, FR-32 |
| `lib/models/grocery_item.dart` | Gilbert | FR-14..17 |
| `lib/models/pantry_item.dart` | Gilbert | FR-18..21 |
| `lib/screens/grocery_screen.dart` | Gilbert | FR-14..17 |
| `lib/screens/pantry_screen.dart` | Gilbert | FR-18..21 |
| `lib/screens/insight_screen.dart` | Gilbert | FR-07 |
| `lib/widgets/grocery_item_tile.dart` | Gilbert | FR-14, FR-16 |
| `lib/widgets/pantry_item_tile.dart` | Gilbert | FR-18..21 |
| `lib/models/water_record.dart` | Edbert | FR-22, FR-23 |
| `lib/models/waste_record.dart` | Edbert | FR-24, FR-25, FR-33, FR-34 |
| `lib/models/user_profile.dart` | Edbert | FR-26..28 |
| `lib/models/achievement.dart` | Edbert | FR-37..39 |
| `lib/utils/badge_rules.dart` | Edbert | FR-37 |
| `lib/screens/water_tracker_screen.dart` | Edbert | FR-22, FR-23, FR-31 |
| `lib/screens/food_waste_screen.dart` | Edbert | FR-24, FR-25, FR-33, FR-34 |
| `lib/screens/profile_screen.dart` | Edbert | FR-26..28 |
| `lib/screens/achievements_screen.dart` | Edbert | FR-37..39 |
| `lib/widgets/water_progress_card.dart` | Edbert | FR-22, FR-31 |
| `lib/widgets/waste_item_tile.dart` | Edbert | FR-24, FR-25 |
| `lib/widgets/badge_tile.dart` | Edbert | FR-37, FR-38 |
| `lib/data/mock_data.dart` | Shared | FR-01..40 |
