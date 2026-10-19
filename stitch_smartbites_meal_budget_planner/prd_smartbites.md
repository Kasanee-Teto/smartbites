# SmartBites: Product Requirements Document

**Aplikasi Mobile Perencana Makan Sehat, Hemat, dan Minim Food Waste**

| Item | Keterangan |
|---|---|
| Mata kuliah | Pemrograman Mobile Front-End (Flutter) |
| Proyek | UTS (Minggu 8), dilanjutkan ke Usability Testing (Minggu 15) dan UAS |
| SDGs | SDG 3: Good Health and Well-Being (pendukung: SDG 12.3 pengurangan food waste) |
| Kelompok | Louis, Jesseca, Gilbert, Edbert |
| Teknologi | Flutter, Dart, Material Design 3, `setState()` |
| Versi dokumen | v1.1 (Minggu 3, direvisi setelah masukan dosen) |

---

## 1. Ringkasan Proyek

SmartBites adalah aplikasi mobile front-end yang membantu pengguna merencanakan makanan sehat sesuai budget, mengatur daftar belanja, memantau stok bahan di rumah, mengurangi makanan terbuang, dan mencatat konsumsi air harian. Semua fitur berjalan dengan data lokal (mock data), sehingga aplikasi dapat diuji dan dinilai tanpa koneksi server.

**Prinsip pencatatan:** aplikasi pencatatan harian mudah melelahkan, sehingga semua pencatatan rutin (minum, makan, makanan terbuang) dirancang sederhana: maksimal 2 ketukan, tanpa berpindah menu, dan dapat dibatalkan. Untuk menjaga konsistensi pengguna, SmartBites menambahkan gamifikasi ringan berupa streak harian dan badge pencapaian.

**Pembeda utama:** SmartBites menempatkan budget sebagai pusat perencanaan. Setiap menu, item belanja, dan makanan terbuang dinyatakan dalam Rupiah, sehingga pengguna langsung melihat dampak pilihan makan terhadap kesehatan sekaligus uang saku.

---

## 2. Latar Belakang dan Permasalahan

Mahasiswa, anak kos, dan pekerja muda sering makan seadanya karena keterbatasan uang dan waktu. Pola ini berdampak pada gizi yang tidak seimbang dan konsumsi air yang kurang. Di sisi lain, bahan makanan yang dibeli tanpa rencana sering rusak sebelum terpakai, sehingga uang terbuang dan food waste bertambah.

### 2.1 Permasalahan Utama

- Sulit menyusun menu sehat yang sesuai budget mingguan.
- Belanja tidak terencana, sehingga membeli bahan yang sebenarnya masih ada di rumah.
- Bahan makanan kedaluwarsa tanpa disadari dan akhirnya terbuang.
- Konsumsi air harian tidak tercatat dan sering di bawah kebutuhan.
- Alergi dan preferensi makanan tidak dipertimbangkan saat memilih menu.
- Pencatatan harian yang rumit membuat pengguna cepat lelah dan berhenti memakai aplikasi.

### 2.2 Keterkaitan dengan SDGs

SmartBites berkontribusi pada SDG 3 (Kehidupan Sehat dan Sejahtera) melalui pembiasaan pola makan seimbang dan hidrasi yang cukup. Fitur pencatatan food waste juga mendukung SDG 12 (Konsumsi dan Produksi yang Bertanggung Jawab), khususnya target 12.3 tentang pengurangan sampah makanan.

---

## 3. Tujuan dan Indikator Keberhasilan

| No | Tujuan | Indikator keberhasilan |
|---|---|---|
| 1 | Membantu pengguna menyusun menu harian sesuai budget | Pengguna dapat menyusun rencana makan 1 hari dan melihat status budget dalam waktu di bawah 2 menit |
| 2 | Menyederhanakan pengelolaan belanja dan stok | Success rate tugas Grocery dan Pantry minimal 80% |
| 3 | Meningkatkan kesadaran terhadap food waste | Pengguna dapat mencatat makanan terbuang dan melihat total kerugian bulanan |
| 4 | Mendorong konsumsi air harian | Pengguna dapat mencatat air dan melihat progres terhadap target tanpa bantuan |
| 5 | Antarmuka mudah dipakai dan konsisten | Skor SUS minimal 68 pada usability testing Minggu 15 |
| 6 | Membuat pencatatan harian ringan dan cepat | Setiap pencatatan (minum, makan, makanan terbuang) selesai maksimal 2 ketukan dan di bawah 10 detik, tanpa berpindah tab |
| 7 | Mendorong pengguna konsisten mencatat | Streak dan badge dapat dipahami dan ditemukan pengguna tanpa bantuan |
| 8 | Aplikasi layak diuji oleh kelompok lain | Berjalan tanpa instalasi tambahan, tidak crash pada input tak terduga, dan dapat dipahami penguji baru dalam 2 menit pertama |

---

## 4. Target Pengguna

**Pengguna utama:** mahasiswa, anak kos, dan pekerja muda (usia 18-30 tahun) yang mengatur sendiri uang makan mereka.

| | Persona 1: Rani, 20 tahun | Persona 2: Dimas, 25 tahun |
|---|---|---|
| Profil | Mahasiswa semester 5, tinggal di kos, uang makan terbatas | Karyawan baru, tinggal sendiri, jarang punya waktu memasak |
| Kebutuhan | Menu murah dan bergizi, belanja tidak boros, tidak alergi kacang | Rencana makan cepat, mengingat minum air, mengurangi bahan terbuang |
| Kendala | Sering membeli bahan yang sudah ada, bingung menu hemat | Sibuk, lupa stok di kulkas, sering membuang sayur |
| Harapan | Tahu sisa budget mingguan dan daftar belanja yang jelas | Tampilan ringkas, sedikit langkah, peringatan bahan hampir habis |

---

## 5. Ruang Lingkup

### 5.1 Dalam Lingkup (In Scope)

- Aplikasi mobile front-end Flutter dengan Material Design 3.
- Data sementara menggunakan mock data lokal dan state sederhana dengan `setState()`.
- Tampilan responsif untuk HP dan tablet.
- Catat Cepat: pencatatan harian langsung dari Home dan tombol Catat Cepat tanpa berpindah menu.
- Gamifikasi ringan: streak harian dan 8 badge pencapaian.
- Penyimpanan ringan di perangkat (`shared_preferences`) bila waktu memungkinkan.

### 5.2 Di Luar Lingkup (Out of Scope)

- Backend dan basis data server (PostgreSQL). Dicatat sebagai pengembangan lanjutan di luar mata kuliah.
- Login dan akun pengguna, sinkronisasi antar perangkat.
- Notifikasi pengingat, pemindaian struk atau kamera, dan resep otomatis berbasis AI.
- Perhitungan gizi medis. Kalori bersifat estimasi dan bukan saran medis.

---

## 6. Kebutuhan Fungsional

Prioritas: **M** = Must-have (wajib ada dan diuji di Minggu 15), **S** = Should-have (dikerjakan bila waktu tersedia).

| ID | Kebutuhan | Prio | PIC |
|---|---|---|---|
| FR-01 | Welcome dan onboarding 3 slide (`PageView` dengan indikator) menjelaskan tujuan dan SDG 3 | M | Louis |
| FR-02 | Navigasi utama: `NavigationBar` di HP, `NavigationRail` di tablet | M | Louis |
| FR-03 | Tema Material Design 3 terang dan gelap (`ColorScheme.fromSeed`) | M | Louis |
| FR-04 | Home: kartu ringkasan budget (terpakai, sisa, status) | M | Louis |
| FR-05 | Home: ringkasan menu hari ini dan ringkasan air | M | Louis |
| FR-06 | Home: kartu Health Tip yang dapat digeser | S | Louis |
| FR-07 | Halaman Insight mingguan (bar chart sederhana dari widget, tanpa package) | S | Gilbert |
| FR-08 | Daftar menu dengan filter kategori (`ChoiceChip`): Sarapan, Siang, Malam, Hemat, Tinggi Protein | M | Jesseca |
| FR-09 | Meal Planner per hari (Senin-Minggu) dengan tiga waktu makan | M | Jesseca |
| FR-10 | Tambah dan hapus menu ke rencana melalui bottom sheet | M | Jesseca |
| FR-11 | Meal Detail: gambar, bahan, harga, kalori, waktu masak, langkah singkat | M | Jesseca |
| FR-12 | Peringatan alergi pada kartu dan detail menu berdasarkan data Profile | M | Jesseca |
| FR-13 | Total harga rencana mingguan dan status hemat / pas / melebihi budget | M | Jesseca |
| FR-14 | Grocery List: daftar item dengan centang dan total perkiraan harga | M | Gilbert |
| FR-15 | Tambah item belanja lewat kolom input inline di atas daftar (ketik lalu Enter), tanpa dialog atau pindah halaman | M | Gilbert |
| FR-16 | Geser untuk menghapus item (`Dismissible`) dengan opsi batal (`SnackBar`) | M | Gilbert |
| FR-17 | Tombol "Pindahkan ke Pantry" untuk item yang sudah dibeli | M | Gilbert |
| FR-18 | Pantry: daftar stok dikelompokkan per kategori | M | Gilbert |
| FR-19 | Indikator stok menipis (`LinearProgressIndicator` dan label) | M | Gilbert |
| FR-20 | Badge kedaluwarsa: Aman, Segera habis, Kedaluwarsa | M | Gilbert |
| FR-21 | Ubah jumlah stok langsung di baris dengan tombol + dan - (stepper) | S | Gilbert |
| FR-22 | Water Tracker: progres target dan tombol tambah +150 / +250 / +500 ml | M | Edbert |
| FR-23 | Riwayat minum hari ini dan status target tercapai | M | Edbert |
| FR-24 | Food Waste: form catat (item, porsi, alasan, estimasi Rp) | M | Edbert |
| FR-25 | Riwayat food waste dan total kerugian bulan ini | M | Edbert |
| FR-26 | Profile: budget mingguan dan target air (`Slider`) | M | Edbert |
| FR-27 | Profile: alergi dan preferensi makanan (`FilterChip`) | M | Edbert |
| FR-28 | Profile: sakelar mode gelap dan tombol Reset Data Demo | M | Edbert |
| FR-29 | Penyimpanan lokal dengan `shared_preferences` untuk budget, air, centang belanja, streak, dan badge. Untuk demo, data awal berisi streak contoh 5 hari | S | Louis |
| FR-30 | Tombol Catat Cepat (Extended FAB) di semua tab utama; membuka bottom sheet berisi aksi Minum, Makan, dan Buang makanan | M | Louis |
| FR-31 | Catat minum satu ketukan (+150 / +250 / +500 ml) langsung dari kartu air di Home dan dari Catat Cepat | M | Edbert |
| FR-32 | Catat makan: centang "Sudah dimakan" pada menu hari ini di Home dan `MealCard` | M | Jesseca |
| FR-33 | Catat food waste cepat: pilih item dari chip (dari Pantry atau menu terakhir), pilih porsi (sedikit / setengah / semua), estimasi harga terisi otomatis, field lain opsional | M | Edbert |
| FR-34 | Tombol "Tidak ada yang terbuang hari ini" yang dihitung sebagai catatan harian | M | Edbert |
| FR-35 | Semua pencatatan memberi umpan balik `SnackBar` dengan tombol Undo | M | Semua |
| FR-36 | Streak harian: hari berturut-turut dengan minimal satu catatan, ditampilkan sebagai kartu di Home | M | Louis |
| FR-37 | Sistem badge dengan 8 badge dan aturan pembukaan berbasis data yang sudah ada | M | Edbert |
| FR-38 | Halaman Pencapaian: grid badge terbuka/terkunci dengan progres, dibuka dari Profile dan kartu streak | M | Edbert |
| FR-39 | Selebrasi saat badge terbuka (dialog atau animasi ringan) | S | Edbert |
| FR-40 | Toleransi satu hari libur agar streak tidak langsung putus (streak freeze) | S | Louis |

> **Catatan teknis:** karena state hanya memakai `setState()`, data yang dipakai lintas halaman (budget, rencana menu, pantry, air, alergi) disimpan di satu widget induk (`MainNavigation`) dan dikirim ke halaman anak lewat constructor beserta callback. Pendekatan ini disepakati sejak awal agar tidak ada state ganda antar halaman.

### 6.1 Prinsip Pencatatan Cepat

- **Maksimal 2 ketukan** untuk satu pencatatan, dan di bawah 10 detik.
- **Tanpa berpindah menu:** aksi minum dan makan ada di Home, sedangkan tombol Catat Cepat tersedia di semua tab.
- **Nilai default cerdas:** jumlah air terakhir diingat, estimasi harga terisi otomatis dari data Pantry, dan porsi memakai pilihan chip, bukan mengetik.
- **Field minimal:** hanya satu isian wajib per pencatatan, sisanya opsional.
- **Mudah dibatalkan:** setiap pencatatan dapat di-Undo melalui `SnackBar`, sehingga pengguna tidak takut salah ketuk.
- **Tanpa dialog berlapis:** pakai bottom sheet satu layar dan input inline, bukan dialog bertingkat.

### 6.2 Gamifikasi: Streak dan Badge

Streak dihitung dari jumlah hari berturut-turut yang memiliki minimal satu catatan (minum, makan, belanja, atau waste). Badge dibuka dari data yang sudah ada, sehingga tidak perlu input tambahan dari pengguna.

| Badge | Syarat pembukaan | Sumber data |
|---|---|---|
| Langkah Pertama | Membuat catatan pertama apa pun | Catatan harian |
| Streak 3 Hari | Mencatat 3 hari berturut-turut | Streak |
| Streak 7 Hari | Mencatat 7 hari berturut-turut | Streak |
| Hidrasi Hero | Target air tercapai 3 hari | Water Tracker |
| Perencana Handal | Rencana makan terisi penuh selama 1 minggu | Meal Planner |
| Dompet Aman | Total rencana mingguan tidak melebihi budget | Budget |
| Pahlawan Anti-Waste | Menandai "tidak ada yang terbuang" 7 hari berturut-turut | Food Waste |
| Belanja Cerdas | Semua item belanja dicentang dan dipindahkan ke Pantry | Grocery dan Pantry |

**Catatan desain:** gamifikasi dibuat ramah, tanpa kata-kata yang menyalahkan saat streak putus, dan toleransi satu hari libur (FR-40) menjaga motivasi. Fitur ini adalah lapisan di atas data yang ada, sehingga risikonya terhadap jadwal rendah.

---

## 7. Alur Halaman dan Navigasi

Alur masuk: Welcome/Onboarding, lalu masuk ke kerangka navigasi utama dengan lima tab.

| Tab | Halaman | Halaman turunan |
|---|---|---|
| 1. Beranda | Home (kartu air, menu hari ini, kartu streak) | Insight mingguan, Pencapaian (ketuk kartu streak) |
| 2. Menu | Meal Planner | Meal Detail (`Navigator.push`), Bottom sheet Tambah Menu |
| 3. Belanja | Grocery List dan Pantry (dua tab dalam satu halaman) | Dialog Tambah Item |
| 4. Air | Water Tracker dan Food Waste (dua tab) | Form Catat Food Waste |
| 5. Profil | Profile | Pencapaian (badge dan streak), pengaturan alergi dan preferensi |
| Semua tab | Tombol Catat Cepat (Extended FAB) | Bottom sheet: Minum, Makan, Buang makanan |

Total: sekitar 14-15 layar dan sub-layar (Welcome, Onboarding, Home, Insight, Meal Planner, Meal Detail, Tambah Menu, Grocery, Pantry, Water, Food Waste, Catat Cepat, Profile, Pencapaian).

**Perilaku responsif:** layar *compact* (kurang dari 600 dp) memakai `NavigationBar` dan satu kolom. Layar *medium* (600-839 dp) memakai `NavigationRail` dan `GridView` 2 kolom. Layar *expanded* (840 dp ke atas) memakai `NavigationRail` dan tata letak dua panel, misalnya daftar menu di kiri dan detail di kanan.

---

## 8. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| Desain | Konsisten dengan Material Design 3: skema warna dari seed color, tipografi `TextTheme`, komponen Card, Chip, NavigationBar, FilledButton |
| Responsif | Tidak ada overflow pada lebar 360 dp hingga 1024 dp; diuji pada emulator HP dan tablet |
| Ketahanan | Input kosong, angka negatif, dan budget 0 ditangani dengan validasi; tidak ada crash |
| Empty state | Setiap daftar memiliki tampilan kosong yang informatif |
| Aksesibilitas | Kontras teks memadai, target sentuh minimal 48 dp, ikon disertai label atau tooltip |
| Kualitas kode | Penamaan Dart konsisten, tidak ada duplikasi UI, widget berulang dijadikan reusable widget, `flutter analyze` bersih |
| Kemandirian | Dapat dijalankan dari APK release atau versi web tanpa konfigurasi tambahan |
| Pencatatan cepat | Setiap pencatatan harian maksimal 2 ketukan dan di bawah 10 detik tanpa berpindah tab, dengan Undo |
| Data awal | Mock data realistis berbahasa Indonesia dengan harga dalam Rupiah dan bahan lokal (tempe, tahu, telur, sayur) |

---

## 9. Arsitektur dan Struktur Proyek

### 9.1 Struktur Folder

```text
smartbites/ (budget_bites)
|-- assets/
|   |-- images/  logo.png, chickpea_bowl.png, vegetable_toast.png, oatmeal.png, ...
|   `-- icons/   water_drop.png
|-- lib/
|   |-- main.dart, app.dart
|   |-- models/  meal.dart, grocery_item.dart, pantry_item.dart,
|   |            water_record.dart, waste_record.dart, user_profile.dart,
|   |            daily_log.dart, achievement.dart
|   |-- data/    mock_data.dart
|   |-- screens/ welcome, onboarding, home, insight, meal_plan, meal_detail,
|   |            grocery, pantry, water_tracker, food_waste, profile,
|   |            achievements
|   |-- widgets/ app_logo, budget_card, meal_card, grocery_item_tile,
|   |            pantry_item_tile, water_progress_card, waste_item_tile,
|   |            section_title, main_navigation, responsive_layout,
|   |            quick_log_sheet, streak_card, badge_tile
|   |-- theme/   app_theme.dart
|   `-- utils/   app_colors, app_constants, responsive_breakpoints, badge_rules
|-- pubspec.yaml
`-- README.md
```

### 9.2 Model Data

| Model | Atribut utama |
|---|---|
| `Meal` | id, name, category, imageAsset, price, calories, cookTimeMinutes, ingredients, allergens, steps |
| `GroceryItem` | id, name, quantity, unit, price, isChecked |
| `PantryItem` | id, name, category, quantity, minQuantity, unit, expiryDate |
| `WaterRecord` | id, amountMl, time |
| `WasteRecord` | id, itemName, portion, reason, estimatedLoss, date |
| `DailyLog` | date, waterMl, mealsEaten, wasteLogged, noWasteMarked |
| `Achievement` | id, title, description, iconAsset, target, progress, isUnlocked |
| `UserProfile` | weeklyBudget, waterTargetMl, allergies, preferences, darkMode |

### 9.3 Reusable Widget

| Widget | Fungsi | Dipakai di |
|---|---|---|
| `BudgetCard` | Ringkasan budget dan status hemat/pas/lewat | Home, Meal Planner |
| `MealCard` | Kartu menu: gambar, harga, kalori, badge alergi | Meal Planner, Home |
| `GroceryItemTile` | Baris item belanja dengan centang dan harga | Grocery |
| `PantryItemTile` | Baris stok dengan indikator dan badge kedaluwarsa | Pantry |
| `WaterProgressCard` | Progres air dan tombol tambah | Home, Water Tracker |
| `WasteItemTile` | Baris riwayat makanan terbuang | Food Waste |
| `SectionTitle`, `AppLogo` | Judul seksi dan logo | Semua halaman |
| `ResponsiveLayout` | Memilih tata letak sesuai lebar layar | Semua halaman utama |
| `QuickLogSheet` | Bottom sheet Catat Cepat: Minum, Makan, Buang makanan | Semua tab (via FAB) |
| `StreakCard` | Jumlah hari streak dan progres menuju badge | Home, Pencapaian |
| `BadgeTile` | Badge terbuka atau terkunci beserta progres | Pencapaian |

---

## 10. Pemetaan Materi Pertemuan 1-7

| Materi | Penerapan di SmartBites |
|---|---|
| Widget dasar | Text, Icon, Image.asset, CircleAvatar, Card, Chip, Button, TextField, Slider, Switch |
| Layout single-child | Container, Padding, Center, Align, SizedBox, Expanded |
| Layout multi-child | Row, Column, ListView, GridView, Stack, Wrap |
| Material Design 3 | `ColorScheme.fromSeed`, `TextTheme`, NavigationBar/Rail, tema terang dan gelap |
| Reusable widget | Dua belas widget pada bagian 9.3 sebagai komponen berulang |
| Asset | Logo, foto menu, dan ikon di `assets/images` dan `assets/icons` |
| Responsive UI | `LayoutBuilder`, `MediaQuery`, breakpoint 600/840 dp, Grid adaptif, tata letak dua panel |

---

## 11. Rencana Usability Testing (Minggu 15)

**Responden:** minimal 5 orang (ideal 5-8) di luar kelompok, sesuai target pengguna. Data yang dicatat: usia, pekerjaan, kebiasaan belanja dan memasak.

| Kode | Skenario tugas | Fitur terkait |
|---|---|---|
| T1 | Atur budget mingguan Rp 300.000 dan alergi kacang | Profile |
| T2 | Tambahkan menu sarapan untuk hari Senin dan lihat kalorinya | Meal Planner, Meal Detail |
| T3 | Temukan bahan yang harus dibeli dan centang dua item | Grocery |
| T4 | Cari bahan di pantry yang stoknya hampir habis | Pantry |
| T5 | Dari Home, catat minum 500 ml tanpa pindah halaman dan cek target | Home, Catat Cepat |
| T6 | Catat satu makanan terbuang lewat tombol Catat Cepat | Catat Cepat, Food Waste |
| T7 | Lihat streak Anda dan temukan satu badge yang belum terbuka | Streak, Pencapaian |

| Metrik | Cara ukur | Target |
|---|---|---|
| Success rate | Persentase tugas selesai tanpa bantuan | 80% atau lebih |
| Time on task | Stopwatch per tugas (detik) | Dicatat, dibandingkan antar tugas |
| Error rate | Jumlah salah tap atau salah jalur per tugas | Rata-rata di bawah 1 per tugas |
| Jumlah ketukan | Ketukan untuk menyelesaikan pencatatan harian (T5 dan T6) | 2 atau kurang |
| SUS | 10 pertanyaan standar via formulir | 68 atau lebih |
| Kualitatif | Catatan think-aloud dan 2-3 pertanyaan penutup | Temuan disertai akar penyebab |

**Bukti pengujian:** foto atau rekaman layar sesi (dengan izin responden), lembar observasi, hasil formulir SUS, dan formulir persetujuan singkat.

---

## 12. Kesiapan Peer Testing (UAS)

- **Distribusi:** APK release dan versi web (`flutter build web`) sebagai cadangan bagi penguji non-Android.
- **Paket penguji:** deskripsi aplikasi, cara instal, daftar tugas uji, perangkat yang sudah diuji, dan kontak kelompok.
- **Mandiri:** data awal realistis, onboarding singkat, tombol Reset Data Demo, dan tidak ada tombol yang tidak berfungsi.
- **Sebagai penilai:** kelompok menyiapkan instrumen evaluasi untuk proyek lain: checklist fungsionalitas, penilaian UI Material Design 3 dan responsivitas, SUS, serta kolom temuan bug (langkah, hasil diharapkan, hasil aktual, screenshot).

---

## 13. Pembagian Tugas dan Jadwal

Pembagian dibuat seimbang dan setiap anggota memegang variasi layout berbeda, sehingga dapat menjelaskan kodenya saat demo. Posisi saat dokumen ini disusun adalah Minggu 3.

### 13.1 Tanggung Jawab per Anggota

| Anggota | Cakupan | Layout dominan |
|---|---|---|
| Louis | Tema M3, `app.dart`, navigasi utama dan state induk, `responsive_layout`, Welcome dan Onboarding, Home, `BudgetCard`, `SectionTitle`, `AppLogo`, `QuickLogSheet` dan FAB, `StreakCard` dan logika streak, model `DailyLog`, persistensi lokal | Stack, GridView, LayoutBuilder |
| Jesseca | Model dan mock data Meal, Meal Planner, Meal Detail, `MealCard`, filter chip, bottom sheet tambah menu, peringatan alergi, centang "Sudah dimakan", aksi Makan di Catat Cepat, koordinasi video demo | ListView, Stack, Wrap |
| Gilbert | Model Grocery dan Pantry, Grocery List dengan input inline, Pantry dengan stepper, `GroceryItemTile`, `PantryItemTile`, alur Grocery ke Pantry, badge stok dan kedaluwarsa, Insight, skrip usability testing | ListView, ListTile, Dismissible |
| Edbert | Model Water, Waste, UserProfile, Achievement, Water Tracker, Food Waste cepat, Profile, `WaterProgressCard`, `WasteItemTile`, Reset Data, sistem badge dan halaman Pencapaian, `BadgeTile` | Column, Row, Slider, GridView |

### 13.2 Jadwal per Blok

**Louis**

| Blok | Tugas |
|---|---|
| Blok 1: Minggu 3 (sisa waktu) | Repo GitHub dan branch; struktur folder dan `app_theme`; kerangka `MainNavigation` dan state induk (`DailyLog`); `responsive_layout`; finalisasi PRD v1.1 |
| Blok 2: Minggu 4-6 | Welcome dan Onboarding; Home dengan `BudgetCard`; tombol Catat Cepat dan kerangka `QuickLogSheet`; `StreakCard` dan logika streak; integrasi state induk |
| Blok 3: Minggu 7-8 | Integrasi budget lintas fitur; uji tablet Home; Health Tip dan streak freeze (opsional); laporan bagian arsitektur |

**Jesseca**

| Blok | Tugas |
|---|---|
| Blok 1: Minggu 3 (sisa waktu) | Wireframe Meal; model `Meal` dan mock data (minimal 10 menu); kerangka layar Meal Planner |
| Blok 2: Minggu 4-6 | Meal Planner dan filter chip; Meal Detail dengan Stack; bottom sheet tambah menu; peringatan alergi; centang "Sudah dimakan" di `MealCard` dan Home |
| Blok 3: Minggu 7-8 | Total dan status budget; tata letak dua panel tablet; aksi Makan di Catat Cepat; perbaikan bug Meal; koordinasi video demo; laporan bagian desain dan Meal |

**Gilbert**

| Blok | Tugas |
|---|---|
| Blok 1: Minggu 3 (sisa waktu) | Wireframe Grocery dan Pantry; model dan mock data; kerangka layar Grocery dan Pantry |
| Blok 2: Minggu 4-6 | Grocery: centang, total, input inline; Dismissible dan SnackBar Undo; Pantry per kategori, indikator stok, badge kedaluwarsa, stepper; alur Grocery ke Pantry |
| Blok 3: Minggu 7-8 | Insight (opsional); uji layar kecil dan tablet; validasi input; skrip uji usability; laporan bagian pengujian |

**Edbert**

| Blok | Tugas |
|---|---|
| Blok 1: Minggu 3 (sisa waktu) | Wireframe Water, Waste, Profile, Pencapaian; model `Water`, `Waste`, `UserProfile`, `Achievement`; rancangan 8 badge dan aturan buka; kerangka layar |
| Blok 2: Minggu 4-6 | Water Tracker dan tombol cepat +ml; Food Waste cepat (chip, porsi, harga otomatis); tombol "Tidak ada yang terbuang"; Profile (Slider, chip, Switch); Reset Data Demo |
| Blok 3: Minggu 7-8 | Sistem badge (`badge_rules`); halaman Pencapaian dan `BadgeTile`; selebrasi badge (opsional); uji responsif; laporan bagian data dan Profile |

### 13.3 Bukti Kontribusi untuk Dosen

- Satu branch per anggota, digabung melalui pull request, sehingga riwayat commit menunjukkan kontribusi masing-masing.
- Log AI/vibecoding per anggota: prompt, hasil, modifikasi, dan bug yang diperbaiki (laporan Pertemuan 2).
- Tabel pembagian tugas di laporan lengkap dengan nama file yang dipegang setiap anggota.
- Setiap anggota siap menjelaskan dan memodifikasi kode bagiannya saat demo.

### 13.4 Jadwal Setelah UTS

| Periode | Kegiatan |
|---|---|
| Minggu 9-13 | Melengkapi fitur Should-have, polishing UI, uji internal, dan persiapan build release |
| Minggu 14 | Merekrut responden dan menyiapkan skrip serta formulir usability testing |
| Minggu 15 | Usability testing dengan pengguna eksternal, laporan, dan presentasi di Teams |
| Setelah Minggu 15 | Perbaikan berdasarkan temuan, build final (APK dan web), paket penguji |
| UAS | Demo, peer testing oleh kelompok lain, dan penilaian proyek kelompok lain |

---

## 14. Penggunaan AI/Vibecoding

AI dipakai sebagai alat bantu, bukan pengganti pemahaman. Aturan kelompok:

1. Setiap prompt dan hasil penting dicatat dalam log AI masing-masing anggota.
2. Kode hasil AI wajib dibaca, dijalankan, dan diuji sebelum digabung.
3. Setiap anggota mengubah minimal satu bagian kode secara mandiri (misalnya warna, layout, atau logika) dan mencatatnya.
4. Bug dan overflow yang muncul dicatat beserta cara memperbaikinya.
5. Pull request tidak digabung sebelum `flutter analyze` bersih dan layar diuji di HP dan tablet.

---

## 15. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Beban tidak seimbang antar anggota | Anggota tertentu terlambat | Cek progres mingguan; Louis menyelesaikan fondasi paling awal |
| State ganda antar halaman | Data tidak sinkron | State dipusatkan di `MainNavigation` sejak awal |
| Overflow di layar kecil atau tablet | Nilai responsif turun | Uji rutin di beberapa ukuran emulator setiap pull request |
| Build APK gagal mendekati tenggat | Peer testing terhambat | Coba `flutter build apk` sejak Minggu 4 dan ulangi tiap blok |
| Sulit mendapat responden eksternal | Data usability kurang | Mulai merekrut di Minggu 12-13, siapkan cadangan responden |
| Kode AI tidak dipahami | Gagal menjelaskan saat demo | Sesi saling menjelaskan kode antar anggota sebelum demo |
| Scope membengkak karena Catat Cepat dan gamifikasi | Fitur inti tidak selesai | Badge berbasis aturan sederhana dari data yang ada; selebrasi dan streak freeze berstatus opsional |
| Gamifikasi terasa menekan pengguna | Pengguna berhenti memakai aplikasi | Bahasa ramah, tanpa kata menyalahkan, toleransi satu hari libur |
| Konflik merge | Waktu terbuang | Satu branch per anggota dan file dibagi per anggota |

---

## 16. Definition of Done

Satu fitur dianggap selesai bila:

- Berjalan tanpa error dan `flutter analyze` bersih.
- Tampil benar di layar compact dan medium/expanded tanpa overflow.
- Memakai tema Material Design 3 dan reusable widget yang ada.
- Input tak valid dan daftar kosong ditangani.
- Sudah di-review lewat pull request dan pemilik kode dapat menjelaskannya.
