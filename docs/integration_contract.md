# SmartBites Integration Contract & State Architecture (Step 2)

This document serves as the official integration contract between team members **Louis**, **Jessica**, **Gilbert**, and **Edbert**. It establishes a shared approach for parallel feature development intended to avoid merge conflicts, without third-party state-management dependencies, while adhering closely to the HTML designs in `stitch_smartbites_meal_budget_planner/`.

---

## 1. State Architecture: Single Source of Truth

Following the PRD principles and the project's technical constraints:

- All shared application state is managed exclusively within `_MainNavigationState` (`lib/widgets/main_navigation.dart`) using standard Flutter `setState()`.
- Data is passed to child screens through constructor parameters (**constructor injection**).
- Child screens request data changes through **typed callbacks** passed down by the parent (`ValueChanged<T>`, `VoidCallback`, etc.).
- Destructive mutations and logging operations are handled through the `_applyWithUndo(String message, VoidCallback apply, VoidCallback revert)` helper, which displays a floating `SnackBar` with an Undo action labeled “Urungkan.”

---

## 2. Table 1: Screen Integration Contract

| Screen | Owner | Design File (HTML Reference) | Parameters Passed In | Callbacks Passed In | State Fields Read |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **HomeScreen** | Louis | `smartbites_beranda/code.html` | `UserProfile profile`, `List<Meal> todayMeals`, `List<bool> todayEaten`, `int totalWeeklyBudget`, `int currentSpent`, `int todayWaterMl`, `int streakDays` | `ValueChanged<int>? onQuickWaterAdd`, `void Function(int slotIndex, bool eaten)? onToggleMealEaten`, `VoidCallback? onOpenMealPlan`, `VoidCallback? onOpenInsight`, `VoidCallback? onOpenStreak` | `_profile`, `_meals`, `_weekPlan[0]`, `_eaten[0]`, `_waterRecords`, `_grocery` |
| **MealPlanScreen** | Jessica | `smartbites_perencana_makan/code.html` | `List<List<String>> weekPlan`, `List<List<bool>> eaten`, `List<Meal> meals`, `int weeklyBudget` | `void Function(int dayIndex, int slotIndex, String newMealId)? onSwapMeal`, `void Function(int dayIndex, int slotIndex)? onDeleteMeal`, `void Function(int dayIndex, int slotIndex, bool eaten)? onToggleMealEaten`, `ValueChanged<Meal>? onMealTap` | `_weekPlan`, `_eaten`, `_meals`, `_profile.weeklyBudget` |
| **MealDetailScreen** | Jessica | `smartbites_detail_resep_alergi/code.html` | `Meal? meal`, `List<String> userAllergies` | `ValueChanged<Meal>? onAddToGrocery`, `VoidCallback? onBack` | `_meals`, `_profile.allergies` |
| **GroceryScreen** | Gilbert | `smartbites_belanja_pantry/code.html` | `List<GroceryItem> items`, `int weeklyBudget` | `ValueChanged<String>? onToggleItem`, `ValueChanged<GroceryItem>? onAddItem`, `ValueChanged<String>? onDeleteItem`, `VoidCallback? onClearChecked` | `_grocery`, `_profile.weeklyBudget` |
| **PantryScreen** | Gilbert | `smartbites_belanja_pantry/code.html` | `List<PantryItem> items` | `ValueChanged<PantryItem>? onAddItem`, `ValueChanged<PantryItem>? onUpdateItem`, `ValueChanged<String>? onDeleteItem` | `_pantry` |
| **WaterTrackerScreen** | Edbert | `smartbites_air_food_waste/code.html` | `int dailyTargetMl`, `int currentWaterMl`, `List<WaterRecord> records` | `ValueChanged<int>? onAddWater`, `ValueChanged<String>? onDeleteRecord` | `_waterRecords`, `_profile.waterTargetMl` |
| **FoodWasteScreen** | Edbert | `smartbites_air_food_waste/code.html` | `List<WasteRecord> records` | `ValueChanged<WasteRecord>? onAddRecord`, `ValueChanged<String>? onDeleteRecord` | `_wasteRecords` |
| **ProfileScreen** | Edbert | `smartbites_profil_pencapaian/code.html` | `UserProfile profile` | `ValueChanged<UserProfile>? onUpdateProfile`, `VoidCallback? onResetData` | `_profile` |
| **AchievementsScreen** | Edbert | `smartbites_profil_pencapaian/code.html` | `List<Achievement> achievements`, `int currentStreak` | `VoidCallback? onBack` | `_achievements`, `_dailyLogs` |
| **InsightScreen** | Gilbert | `smartbites_beranda/code.html` | `int currentSpent`, `int weeklyBudget` | `VoidCallback? onBack` | `_grocery`, `_profile.weeklyBudget` |
| **WelcomeScreen** | Louis | `smartbites_welcome_onboarding/code.html` | — | `VoidCallback? onGetStarted` | — |
| **OnboardingScreen** | Louis | `smartbites_welcome_onboarding/code.html` | — | `ValueChanged<UserProfile>? onFinish` | — |

---

## 3. Table 2: Shared Components and Widgets

| Widget | Built By | Used On | Description and Purpose |
| :--- | :--- | :--- | :--- |
| **SmartBitesAppBar** | Louis | All main tabs: Home, Meals, Shopping, Water, and Profile | A consistent top app bar with an SVG/PNG logo, SDG 3 and 12.3 pill badges, a streak counter chip, a notification button, and a profile avatar. |
| **AppLogo** | Louis | `SmartBitesAppBar`, `WelcomeScreen`, `OnboardingScreen` | Application logo widget with an asset fallback and configurable size (`size`). |
| **SectionTitle** | Louis | `HomeScreen`, `MealPlanScreen`, `ProfileScreen`, etc. | A section heading using standard M3 typography, with an optional trailing action. |
| **StatusBadge** | Louis | `BudgetCard`, `MealCard`, `GroceryItemTile`, `PantryItemTile` | Consistent status badges: `.hemat()`, `.pas()`, `.melebihi()`, and `.alergen()`. |
| **ResponsiveLayout** | Louis | Root containers across all screens | Adaptive `LayoutBuilder` breakpoints: compact (<600 dp), medium (600–839 dp), and expanded (≥840 dp). |
| **PageDots** | Louis (Step 3) | `OnboardingScreen`, `HealthTipCard` (Step 10) | Material 3 pagination dots with accessibility `Semantics` and smooth transition animations (addition to PRD 9.1). |
| **SdgBadge** | Louis (Step 3) | `WelcomeScreen`, `OnboardingScreen`, `SmartBitesAppBar` | A badge representing the project's SDG 3 (Good Health) and SDG 12.3 (Zero Food Waste) aspirations, with regular and compact modes. |
| **AssetImageWithFallback** | Louis (Step 3) | `OnboardingScreen`, `HomeScreen`, `MealCard` | A local asset-image component with a safe, theme-based `errorBuilder` fallback when an image file has not yet been downloaded. |
| **BudgetCard** | Louis (Step 5) | `HomeScreen`, `MealPlanScreen` | A weekly budget summary card with a linear gauge bar and status badge. |
| **StreakCard** | Louis (Step 5) | `HomeScreen`, `AchievementsScreen` | A consecutive-day streak card with a flame icon, milestone level, and navigation to achievements. |
| **QuickLogSheet** | Louis (Step 4) | Global FAB (`Catat Cepat`, meaning Quick Log) | A modal bottom sheet with multiple actions for logging water, marking lunch as eaten, and recording food waste with one tap. |
| **MealCard** | Jessica (Step 6) | `HomeScreen`, `MealPlanScreen` | A meal card with a photo, calories, price, allergen tags, and a checkbox for marking the meal as eaten. |
| **GroceryItemTile** | Gilbert (Step 7) | `GroceryScreen` | A grocery-list item with a checkbox, quantity, estimated price, and swipe-to-delete interaction. |
| **PantryItemTile** | Gilbert (Step 7) | `PantryScreen` | A pantry-list item with a visual expiry warning and a restock button. |
| **WaterProgressCard** | Edbert (Step 8) | `HomeScreen`, `WaterTrackerScreen` | A daily hydration-target visualization with +150 ml, +250 ml, and +500 ml quick-add buttons. |
| **WasteItemTile** | Edbert (Step 8) | `FoodWasteScreen` | A food-waste history card showing estimated financial loss in Rupiah and the reason for the waste. |

---

## 4. Table 3: Data Model Gaps (HTML vs. PRD 9.2)

Based on the comparative audit of eight HTML screens against the PRD 9.2 specification:

| Field Shown in the HTML Design | Screens | Status in PRD 9.2 | Proposed Owner | Notes and Suggested Solution |
| :--- | :--- | :--- | :--- | :--- |
| `name` (“Rani”), `age` (20), `role` (“Active Student Living in a Boarding House”), `avatarAsset` | Home, Profile | Not yet included in `UserProfile` | **Edbert** | Propose adding personal profile fields to `UserProfile`, or retain them as fallback placeholders. |
| `dailyCalorieTarget` (1,800 kcal) | Home, Meals | Not yet included in `UserProfile` | **Edbert** | Needed for comparison with the daily calorie total (`1000 / 1800 kcal`). |
| `scheduledTime` (“07:30”, “12:30”, “19:00”) | Home, Meals | Not yet included in `Meal` | **Jessica** | Meal times can be derived from the slot index (0 = Breakfast at 07:30, 1 = Lunch at 12:30, 2 = Dinner at 19:00) without changing the `Meal` fields. |
| `tags` (“Budget-Friendly”, “High Protein”) | Meals | Not yet included in `Meal`; only `category` exists | **Jessica** | Propose adding `List<String> tags` to `Meal` for the pill-shaped filter bar. |
| `category` (“Protein”, “Vegetables”, “Seasonings”) | Shopping | Not yet included in `GroceryItem` | **Gilbert** | Propose adding `String category` to `GroceryItem` for grocery-list grouping. |
| `storeName` (“Traditional Market”, “Convenience Store”) | Shopping | Not yet included in `GroceryItem` | **Gilbert** | Needed if Gilbert chooses to display the least expensive purchase location. |
| `estimatedLoss` / `purchasePrice` | Pantry | Not yet included in `PantryItem` | **Gilbert** | Pantry items in the HTML show the potential financial loss if they expire. |
| Container labels (“1 Cup”, “1 Glass”, “1 Bottle”) | Home, Water | Not yet included in `WaterRecord` | **Edbert** | Can be handled in the UI presentation layer: 150 ml → Cup, 250 ml → Glass, 500 ml → Bottle. |
| `badgeEmoji` | Profile, Achievements | Not yet included in `Achievement` | **Edbert** | Can be mapped in a UI helper using the achievement ID. |
| Dynamic Streak Count and Level | Home, Profile | Calculated from `DailyLog` | **Louis** | Calculate using a pure function over the `DailyLog` list; no new hardcoded field is needed. |