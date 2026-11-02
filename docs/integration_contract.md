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
| **HomeScreen** | Louis | `smartbites_beranda/code.html` | `UserProfile profile`, `List<Meal> todayMeals`, `List<bool> todayEaten`, `int totalWeeklyBudget`, `int currentSpent`, `int todayWaterMl`, `int streakDays` | `ValueChanged<int>? onQuickWaterAdd`, `void Function(int slotIndex, bool eaten)? onToggleMealEaten`, `VoidCallback? onOpenMealPlan`, `VoidCallback? onOpenInsight`, `VoidCallback? onOpenStreak` | `_profile`, `_plan` (today), `_meals`, `_waterRecords`, `_grocery` |
| **MealPlanScreen** | Jessica | User-supplied planner/calendar/nutrition references and `design.md` | `List<PlannedMeal> entries`, `List<Meal> meals`, `List<String> allergies`, `MealPreferences preferences`, `Map<Nutrient, double> goals`, `NutritionFocus focus`, `int weeklyBudget`, optional `DateTime initialDate` | `ValueChanged<PlannedMeal> onSave`, `ValueChanged<String> onDelete`, `ValueChanged<Map<Nutrient, double>> onGoalsChanged`, `ValueChanged<NutritionFocus> onFocusChanged`, `void Function(Meal, double) onAddToGrocery`, optional `void Function(List<String>, MealPreferences) onPreferencesChanged` | `_plan`, `_meals`, `_nutritionGoals`, `_nutritionFocus`, `_profile` |
| **MealDetailScreen** | Jessica | User-supplied recipe/nutrition references and `design.md` | `Meal meal`, `List<String> userAllergies` | optional `void Function(Meal, double) onAddToGrocery`, `void Function(Meal, double) onPlan`, `VoidCallback onBack` | Read-only meal; portion selection stays local |
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
| **SmartBitesAppBar** | Louis | All main tabs: Home, Meals, Shopping, Water, and Profile | A consistent top app bar with an SVG/PNG logo, SDG 3 and 12 pill badges, a streak counter chip, a notification button, and a profile avatar. |
| **AppLogo** | Louis | `SmartBitesAppBar`, `WelcomeScreen`, `OnboardingScreen` | Application logo widget with an asset fallback and configurable size (`size`). |
| **SectionTitle** | Louis | `HomeScreen`, `MealPlanScreen`, `ProfileScreen`, etc. | A section heading using standard M3 typography, with an optional trailing action. |
| **StatusBadge** | Louis | `BudgetCard`, `MealCard`, `GroceryItemTile`, `PantryItemTile` | Consistent status badges: `.hemat()`, `.pas()`, `.melebihi()`, and `.alergen()`. |
| **ResponsiveLayout** | Louis | Root containers across all screens | Adaptive `LayoutBuilder` breakpoints: compact (<600 dp), medium (600–839 dp), and expanded (≥840 dp). |
| **PageDots** | Louis (Step 3) | `OnboardingScreen`, `HealthTipCard` (Step 10) | Material 3 pagination dots with accessibility `Semantics` and smooth transition animations (addition to PRD 9.1). |
| **SdgBadge** | Louis (Step 3) | `WelcomeScreen`, `OnboardingScreen`, `SmartBitesAppBar` | A badge representing the project's SDG 3 (Good Health) and SDG 12 (Zero Food Waste) aspirations, with regular and compact modes. |
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

## 5. Cook and Buy Meal Options

`MealSource` separates `cook` ("Masak Sendiri") from `buy` ("Beli Siap Makan").
This is independent of `category`, which identifies breakfast, lunch, dinner, or
"Camilan" for desserts, snacks, and snack drinks. Camilan entries are catalog
options; they can be scheduled at any chosen time, alongside the three daily seed meals.
A dish can have separate cook and buy entries with distinct IDs, portions, and
sample prices.

- `Meal(...)` creates a cook option with ingredients, cooking steps, and a cooking
  duration.
- `Meal.buy(...)` creates a ready-to-eat option. Ingredients and cooking steps
  are empty. Cooking time is zero because the user does not cook it; it does not
  describe queue or travel time.
- `price` is a sample cost per serving: an estimated cooking cost for a cook
  option, or an estimated purchase price for a buy option. Calories and allergen
  tags are sample information. An empty allergen list is not an allergen-free
  guarantee; vendor recipes and sauces can vary.
- `mockCookMeals` contains recipes, `mockBuyMeals` contains purchase options, and
  `mockMeals` combines them for the existing `_MainNavigationState` initializer.
  The seed week retains meal IDs and initializes dated `PlannedMeal` records once.

The planner filters the parent's catalog by `source`, category, name, sample price,
cooking duration, profile allergen tags, and an optional per-serving cholesterol
cap. Unknown cholesterol is excluded when that cap is active. Details offer recipe
steps and grocery actions only for cook options. Venue names in meal titles are
examples, not verified businesses or ordering/payment integrations.

The existing dashboard spending figure still sums checked grocery items. These
fixtures do not implement purchased-meal expense logging or include purchases in
that spending total. The planner shows the selected week's estimated cost using each entry's
portion count and its catalog price. This is separate from actual spending.

## 6. Per-Serving Nutrition Estimates

Both meal constructors require `NutritionFacts nutrition`. `Meal.calories`
remains the single calorie value, in kcal for the same serving. Nutrition amounts
are per `servingSize` and `servingSizeGrams`, not per 100 g or per recipe batch.

| Fields | Units | Availability |
| --- | --- | --- |
| `servingSize`, `servingSizeGrams` | Indonesian description, g | Required |
| `totalFatGrams`, `saturatedFatGrams` | g | Required |
| `transFatGrams` | g | Nullable |
| `cholesterolMilligrams`, `sodiumMilligrams` | mg | Cholesterol nullable; sodium required |
| `carbohydrateGrams`, `fiberGrams`, `totalSugarsGrams` | g | Required |
| `addedSugarsGrams` | g, included in total sugars | Nullable |
| `proteinGrams` | g | Required |
| `vitaminDMicrograms` | mcg | Nullable |
| `calciumMilligrams`, `ironMilligrams`, `potassiumMilligrams` | mg | Nullable |

The nutrient selection follows the user's supplied Nutrition Facts image and the
[FDA label explanation](https://www.fda.gov/food/nutrition-facts-label/how-understand-and-use-nutrition-facts-label).
That reference establishes field meanings, not the meal fixture amounts.

All current fixtures use `isEstimate: true` (the default). Amounts, serving
weights, calories, and prices are invented illustrative estimates for the local
prototype. They were not calculated from ingredient analysis, measured, or
verified with vendors. Unknown trans fat, added sugars, cholesterol, and
micronutrients stay null; null must display as "Belum tersedia", not zero.
No daily-value percentages, automatic dietary prescriptions, supplement doses,
or clinical recommendations are implemented. Personal daily targets and limits
are optional values explicitly entered by the user.

Meal details label these values "Estimasi contoh per porsi" and show serving
size and portion scaling. Unknown totals retain their coverage count and do not
appear as meeting a personal limit. Buy fixtures include sample snack prices starting at Rp5.000 and
larger meal portions up to Rp24.000. Compare prices together with their serving
descriptions; these are demonstration values, not an affordability guarantee.

## 7. Calendar and Nutrition Tracker

`_MainNavigationState` owns `_plan`, `_nutritionGoals`, and `_nutritionFocus`.
`mockWeekPlan` and `mockEaten` are seed inputs only; they are not a second mutable
plan. `seedMealPlan` anchors the example week to the device's current Monday.
`PlannedMeal` stores a stable ID, meal ID, local `scheduledAt`, 0.25-10 servings,
and `isEaten`. Calendar day changes use date construction rather than adding
24-hour durations, so month/year boundaries follow local calendar dates.

The screen owns selected date, day/week view, search filters, and open panels.
Day and week navigation, the month date picker, rescheduling, and snacks work
across weeks. Multiple entries at the same time remain separate records. Native
Material date/time pickers use Indonesian in the app. No Google Calendar or
Teams account, API, or calendar synchronization is involved.

The parent applies add/edit/delete/logging and personal goal changes with
`SnackBar` undo. Logging a future calendar date is rejected. Replacing a meal in
the editor resets its eaten flag; changing portions recalculates its contribution.
Deleting, moving, or undoing a consumed entry recomputes affected daily meal-log
IDs while preserving water and waste fields. Home constructor data is derived
from today's entries. Plan and goals are session state and reset on app restart.

Nutrition distinguishes planned amounts from entries marked eaten. Every total
multiplies the catalog amount by servings. `NutrientTotal` keeps a known count and
an entry count: a partial sum is shown with a lower-bound marker and coverage;
an entirely unknown nutrient displays "Belum tersedia". Targets are optional;
no default calorie or medical nutrient target is assigned. The seven-day chart
compares planned and consumed calorie estimates, not weight or clinical outcomes.

"Fokus kolesterol" prioritizes saturated fat in catalog sorting and displays
saturated/trans fat, cholesterol, fiber, and sodium. "Fokus jantung" sorts by sodium
and highlights sodium, saturated fat, fiber, cholesterol, and potassium. These
are comparison tools, not diagnoses or declarations that a dish is appropriate
for a disease. Their nutrient emphasis is informed by the
[American Heart Association's food guidance](https://www.heart.org/en/healthy-living/healthy-eating/healthy-food-facts).
Mock nutrient amounts cannot establish individual suitability. User-entered goals
should follow the user's own needs or professional advice.

Adding ingredients from a recipe scales parsable quantities, including fractions,
and omits plain water. Bought meals generate no groceries. Ingredient names with
no amount retain one recipe portion as the base quantity. Ingredient prices are
not derivable reliably from current recipe strings, so new shopping rows use the
existing zero-price sentinel and display "Harga belum diisi"; the shopping banner
marks the estimate incomplete. Grocery undo removes only the newly added rows.

The implemented scope includes the planner, diary, catalog, nutrition goals,
trends, meal details, and allergy-tag comparison. Food scanning, external AI,
weight-loss prediction, diagnosis, clinical meal prescriptions, and external
ordering are not implemented.

The meal workspace uses three compact sections: Rencana, Gizi, and Menu. All
seven day selectors fit the phone width; a date button opens the month picker.
Focus selection opens a separate sheet. Secondary catalog filters and additional
nutrients expand on request. Large layouts show a nutrition sidebar and the full
week calendar; smaller week views scroll horizontally. The global quick-log FAB
is hidden in this workspace because inline add/log actions remain available.

Focus also sorts scheduled meal cards: Umum restores time order, Kolesterol uses
ascending saturated fat, and Jantung uses ascending sodium, scaled by planned
servings. Ties use time then entry ID; missing meal data sorts last in nutrient
views. The day agenda and diary use this display order. Weekly calendar entries
are sorted only within their original date/time band. No plan entries, times,
consumed flags, or totals are changed by selecting a focus.

Catalog source options use icon cards; category and focus options use decorative
Material icons with text labels and selected states. `OptionIcon` is a shared
visual marker, not a separate interaction. The full nutrition summary groups
energy/macros into rings and wellness nutrients into expandable rows. Rings use
only positive, finite personal goals; unset goals show an empty track and
"Tanpa target". Incomplete nutrient data shows coverage and an empty ring rather
than a fabricated percentage. The compact sidebar remains a row summary.

## 8. Meal preferences

`UserProfile.mealPreferences` holds immutable `MealPreferences` (nullable
`MealDiet? diet`, `int? maxPrice`, and `int? maxCookMinutes`). Profile allergies
remain in `UserProfile.allergies`; legacy `preferences` strings are preserved
and are not interpreted as diet rules. `_MainNavigationState` owns the profile
and applies updates with undo through `_updateProfile`.

`MealPreferencesSheet` receives initial allergies/preferences and a typed
`onSave(List<String>, MealPreferences)` callback. It owns only a draft. Both
ProfileScreen and MealPlanScreen open it. Closing cancels; reset edits the draft;
Save validates and updates the parent. The menu callback preserves weekly
budget, water target, theme flags, and legacy preference strings. No plan/log is
rewritten when preferences change. Manual allergen replacement candidates also
respect the selected diet/budget/time preferences.

Catalog search, category, source, allergen, diet, budget, time, and the local
cholesterol limit combine using AND. Allergens are always excluded according to
the selected profile tags. Budget/time controls now live in the preference
sheet, rather than a second set of local catalog controls. Zero is valid (free
items or no cooking); blank removes a limit. Whole-number limits are 0–10,000,000
Rupiah and 0–1,440 minutes. Bought meals have zero cooking time, not zero wait time.

`Meal.diet` is optional explicit mock metadata. Vegan matches both Vegan and
Vegetarian; untagged meals do not match either dietary filter. 27 listed cook
recipes have tags. Recipes with ambiguous stock/seasoning and all buy fixtures
remain untagged. Tags describe sample recipes, not vendor verification,
certification, allergen safety, or medical suitability.
