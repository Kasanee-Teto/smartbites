# SmartBites Integration Contract & State Architecture (Step 2)

Dokumen ini menjadi kontrak integrasi resmi antara anggota tim (**Louis**, **Jesseca**, **Gilbert**, dan **Edbert**) agar pengembangan fitur dapat berjalan paralel tanpa *merge conflicts*, tanpa dependensi *state management third-party*, dan berpedoman teguh pada desain HTML (`stitch_smartbites_meal_budget_planner/`).

---

## 1. Arsitektur State: Single Source of Truth

Mengikuti prinsip PRD dan batasan teknis proyek:
- Seluruh shared application state dikelola secara eksklusif di dalam `_MainNavigationState` (`lib/widgets/main_navigation.dart`) menggunakan standard Flutter `setState()`.
- Data diteruskan ke child screens melalui parameter konstruktor (*constructor injection*).
- Mutasi data oleh child screens dikembalikan ke parent melalui *typed callbacks* (`ValueChanged<T>`, `VoidCallback`, dsb).
- Operasi mutasi yang bersifat *destructive* atau *logging* dilindungi oleh helper `_applyWithUndo(String message, VoidCallback apply, VoidCallback revert)` yang menampilkan floating `SnackBar` dengan aksi "Urungkan".

---

## 2. Tabel 1: Kontrak Integrasi Layar (Screen Contract)

| Screen | Owner | Design File (HTML Reference) | Parameters Passed In | Callbacks Passed In | State Fields Read |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HomeScreen** | Louis | `smartbites_beranda/code.html` | `UserProfile profile`, `List<Meal> todayMeals`, `List<bool> todayEaten`, `int totalWeeklyBudget`, `int currentSpent`, `int todayWaterMl`, `int streakDays` | `ValueChanged<int>? onQuickWaterAdd`, `void Function(int slotIndex, bool eaten)? onToggleMealEaten`, `VoidCallback? onOpenMealPlan`, `VoidCallback? onOpenInsight`, `VoidCallback? onOpenStreak` | `_profile`, `_meals`, `_weekPlan[0]`, `_eaten[0]`, `_waterRecords`, `_grocery` |
| **MealPlanScreen** | Jesseca | `smartbites_perencana_makan/code.html` | `List<List<String>> weekPlan`, `List<List<bool>> eaten`, `List<Meal> meals`, `int weeklyBudget` | `void Function(int dayIndex, int slotIndex, String newMealId)? onSwapMeal`, `void Function(int dayIndex, int slotIndex)? onDeleteMeal`, `void Function(int dayIndex, int slotIndex, bool eaten)? onToggleMealEaten`, `ValueChanged<Meal>? onMealTap` | `_weekPlan`, `_eaten`, `_meals`, `_profile.weeklyBudget` |
| **MealDetailScreen** | Jesseca | `smartbites_detail_resep_alergi/code.html` | `Meal? meal`, `List<String> userAllergies` | `ValueChanged<Meal>? onAddToGrocery`, `VoidCallback? onBack` | `_meals`, `_profile.allergies` |
| **GroceryScreen** | Gilbert | `smartbites_belanja_pantry/code.html` | `List<GroceryItem> items`, `int weeklyBudget` | `ValueChanged<String>? onToggleItem`, `ValueChanged<GroceryItem>? onAddItem`, `ValueChanged<String>? onDeleteItem`, `VoidCallback? onClearChecked` | `_grocery`, `_profile.weeklyBudget` |
| **PantryScreen** | Gilbert | `smartbites_belanja_pantry/code.html` | `List<PantryItem> items` | `ValueChanged<PantryItem>? onAddItem`, `ValueChanged<PantryItem>? onUpdateItem`, `ValueChanged<String>? onDeleteItem` | `_pantry` |
| **WaterTrackerScreen**| Edbert | `smartbites_air_food_waste/code.html` | `int dailyTargetMl`, `int currentWaterMl`, `List<WaterRecord> records` | `ValueChanged<int>? onAddWater`, `ValueChanged<String>? onDeleteRecord` | `_waterRecords`, `_profile.waterTargetMl` |
| **FoodWasteScreen** | Edbert | `smartbites_air_food_waste/code.html` | `List<WasteRecord> records` | `ValueChanged<WasteRecord>? onAddRecord`, `ValueChanged<String>? onDeleteRecord` | `_wasteRecords` |
| **ProfileScreen** | Edbert | `smartbites_profil_pencapaian/code.html` | `UserProfile profile` | `ValueChanged<UserProfile>? onUpdateProfile`, `VoidCallback? onResetData` | `_profile` |
| **AchievementsScreen**| Edbert | `smartbites_profil_pencapaian/code.html` | `List<Achievement> achievements`, `int currentStreak` | `VoidCallback? onBack` | `_achievements`, `_dailyLogs` |
| **InsightScreen** | Gilbert | `smartbites_beranda/code.html` | `int currentSpent`, `int weeklyBudget` | `VoidCallback? onBack` | `_grocery`, `_profile.weeklyBudget` |
| **WelcomeScreen** | Louis | `smartbites_welcome_onboarding/code.html`| - | `VoidCallback? onGetStarted` | - |
| **OnboardingScreen** | Louis | `smartbites_welcome_onboarding/code.html`| - | `ValueChanged<UserProfile>? onFinish` | - |

---

## 3. Tabel 2: Komponen & Widget Bersama (Shared Widgets)

| Widget | Built By | Digunakan Pada Layar | Deskripsi & Kegunaan |
| :--- | :--- | :--- | :--- |
| **SmartBitesAppBar** | Louis | Semua Tab Utama (Beranda, Menu, Belanja, Air, Profil) | Top App Bar konsisten dengan logo SVG/PNG, pill badge SDG 3 & 12.3, streak counter chip, tombol notifikasi, dan avatar profil. |
| **AppLogo** | Louis | `SmartBitesAppBar`, `WelcomeScreen`, `OnboardingScreen` | Widget logo aplikasi dengan asset fallback dan ukuran dinamis (`size`). |
| **SectionTitle** | Louis | `HomeScreen`, `MealPlanScreen`, `ProfileScreen`, dsb. | Header judul section berstandar typography M3 dengan aksi trailing opsional. |
| **StatusBadge** | Louis | `BudgetCard`, `MealCard`, `GroceryItemTile`, `PantryItemTile` | Badge status seragam: `.hemat()`, `.pas()`, `.melebihi()`, dan `.alergen()`. |
| **ResponsiveLayout** | Louis | Seluruh root container layar | LayoutBuilder adaptive breakpoint: compact (<600dp), medium (600-839dp), dan expanded (≥840dp). |
| **BudgetCard** | Louis (Step 3) | `HomeScreen`, `MealPlanScreen` | Kartu ringkasan anggaran mingguan dengan gauge bar linier dan badge status. |
| **StreakCard** | Louis (Step 3) | `HomeScreen`, `AchievementsScreen` | Kartu streak beruntun dengan icon api, milestone level, dan navigasi ke pencapaian. |
| **QuickLogSheet** | Louis (Step 4) | FAB Global (`Catat Cepat`) | Bottom sheet modal multi-aksi untuk log air, centang makan siang, dan catat sisa makanan 1-ketuk. |
| **MealCard** | Jesseca (Step 6)| `HomeScreen`, `MealPlanScreen` | Kartu item makanan dengan foto, kalori, harga, tag alergen, dan checkbox selesai makan. |
| **GroceryItemTile** | Gilbert (Step 7)| `GroceryScreen` | List item belanja dengan checkbox, kuantitas, estimasi harga, dan swipe-to-delete. |
| **PantryItemTile** | Gilbert (Step 7)| `PantryScreen` | List item pantry dengan visual peringatan kedaluwarsa dan tombol stok ulang. |
| **WaterProgressCard**| Edbert (Step 8) | `HomeScreen`, `WaterTrackerScreen` | Visualizer target hidrasi harian dengan tombol cepat +150ml, +250ml, +500ml. |
| **WasteItemTile** | Edbert (Step 8) | `FoodWasteScreen` | Kartu riwayat makanan terbuang dengan estimasi kerugian rupiah dan alasan sisa. |

---

## 4. Tabel 3: Kesenjangan Model Data (Model Gaps Check: HTML vs PRD 9.2)

Berdasarkan audit komparasi 8 layar HTML terhadap spesifikasi PRD 9.2:

| Field yang Ditampilkan di Desain HTML | Layar Tempat Ditampilkan | Status di PRD 9.2 | Pemilik yang Diajukan (Proposed Owner) | Catatan & Saran Solusi |
| :--- | :--- | :--- | :--- | :--- |
| `name` ("Rani"), `age` (20), `role` ("Mahasiswa Kost Aktif"), `avatarAsset` | Beranda, Profil | ❌ Belum ada di `UserProfile` | **Edbert** | Usulkan penambahan field profil personal ke model `UserProfile` atau biarkan sebagai *fallback placeholder*. |
| `dailyCalorieTarget` (1.800 kkal) | Beranda, Menu | ❌ Belum ada di `UserProfile` | **Edbert** | Diperlukan untuk perbandingan total kalori harian (`1000 / 1800 kkal`). |
| `scheduledTime` ("07:30", "12:30", "19:00") | Beranda, Menu | ❌ Belum ada di `Meal` | **Jesseca** | Slot jadwal makan dapat diturunkan dari indeks slot (0=Sarapan 07:30, 1=Siang 12:30, 2=Malam 19:00) tanpa mengubah field `Meal`. |
| `tags` ("Hemat", "Tinggi Protein") | Menu | ❌ Belum ada di `Meal` (hanya ada `category`) | **Jesseca** | Usulkan penambahan `List<String> tags` pada `Meal` untuk filter pill bar. |
| `category` ("Protein", "Sayuran", "Bumbu") | Belanja | ❌ Belum ada di `GroceryItem` | **Gilbert** | Usulkan penambahan `String category` pada `GroceryItem` untuk pengelompokan list belanja. |
| `storeName` ("Pasar Tradisional", "Minimarket") | Belanja | ❌ Belum ada di `GroceryItem` | **Gilbert** | Diperlukan jika Gilbert ingin menampilkan sumber tempat pembelian termurah. |
| `estimatedLoss` / `purchasePrice` | Pantry | ❌ Belum ada di `PantryItem` | **Gilbert** | Item pantry di HTML menampilkan nilai potensi kerugian jika kedaluwarsa. |
| Container label ("1 Cangkir", "1 Gelas", "1 Botol") | Beranda, Air | ❌ Belum ada di `WaterRecord` | **Edbert** | Cukup dihandle di level UI presenter (150ml $\rightarrow$ Cangkir, 250ml $\rightarrow$ Gelas, 500ml $\rightarrow$ Botol). |
| `badgeEmoji` (🏆, 🔥, 💰, ⚡) | Profil, Pencapaian | ❌ Belum ada di `Achievement` | **Edbert** | Dapat dipetakan di UI helper berdasarkan ID achievement. |
| Dynamic Streak Count & Level | Beranda, Profil | Dihitung dari `DailyLog` | **Louis** | Dihitung secara murni melalui pure function dari list `DailyLog` (tidak perlu hardcoded field baru). |
