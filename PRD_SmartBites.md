# SmartBites: Product Requirements Document

**Mobile App for Healthy, Budget-Friendly Meal Planning and Reduced Food Waste**

| Item | Description |
|---|---|
| Course | Mobile Front-End Programming (Flutter) |
| SDGs | SDG 3: Good Health and Well-Being (supporting alignment: SDG target 12.3 on reducing food waste) |
| Team | Louis, Jessica, Gilbert, Edbert |
| Technology | Flutter, Dart, Material Design 3, `setState()` |
| Document version | v1.1 |

---

## 1. Project Overview

SmartBites is a mobile application designed to help users plan healthy meals within their budget, organize grocery lists, track ingredients at home, reduce food waste, and record daily water intake. All features use local mock data, allowing the application to be tested and assessed without a server connection.

**Logging principle:** Daily tracking applications can become tiring to use. Therefore, routine logging—water intake, meals, and food waste—is designed to be simple: no more than two taps, no menu switching, and an option to undo. To encourage consistent participation, SmartBites includes lightweight gamification through daily streaks and achievement badges.

**Key differentiator:** SmartBites places the budget at the center of planning. Each meal, grocery item, and food-waste entry has a value expressed in Indonesian Rupiah, helping users consider both meal choices and their spending allowance.

## 2. Background and Problem Statement

Students, boarding-house residents, and young professionals may rely on whatever food is readily available because of limited time and money. This project addresses concerns about unbalanced meals and insufficient attention to hydration. Meanwhile, ingredients purchased without a plan may spoil before use, wasting money and increasing food waste.

### 2.1 Main Problems

- Difficulty planning healthy meals within a weekly budget.
- Unplanned shopping that leads to buying ingredients already available at home.
- Ingredients passing their expiry dates unnoticed and eventually being discarded.
- Daily water intake going unrecorded and potentially falling below users' needs.
- Food allergies and preferences being overlooked when selecting meals.
- Complicated daily logging that causes users to become tired and stop using the application.

### 2.2 Alignment with the SDGs

SmartBites aims to support SDG 3 (Good Health and Well-Being) by encouraging awareness of balanced eating and hydration. Food-waste logging also aligns with SDG 12 (Responsible Consumption and Production), particularly target 12.3 on reducing food waste. These are intended contributions rather than demonstrated outcomes.

## 3. Objectives and Success Indicators

The following indicators are evaluation targets, not completed research findings.

| No. | Objective | Success indicator |
|---|---|---|
| 1 | Help users plan daily meals within their budget | Users can create a one-day meal plan and view its budget status in under two minutes. |
| 2 | Simplify grocery and pantry management | At least an 80% task success rate for Grocery and Pantry tasks. |
| 3 | Increase awareness of food waste | Users can log discarded food and view the total estimated financial loss for the month. |
| 4 | Encourage daily water intake awareness | Users can log water intake and view progress toward the configured target without assistance. |
| 5 | Provide a consistent, easy-to-use interface | A System Usability Scale (SUS) score of at least 68 during Week 15 usability testing. |
| 6 | Make daily logging quick and lightweight | Each water, meal, or food-waste entry takes no more than two taps and under ten seconds, without switching tabs. |
| 7 | Encourage consistent logging | Users can understand and find streaks and badges without assistance. |
| 8 | Prepare the application for testing by other groups | The application runs without additional installation requirements, handles unexpected input without crashing, and can be understood by a new tester within the first two minutes. |

## 4. Target Users

**Primary users:** Students, boarding-house residents, and young professionals aged 18–30 who manage their own food budgets.

| Aspect | Persona 1: Rani, age 20 | Persona 2: Dimas, age 25 |
|---|---|---|
| Profile | Fifth-semester university student living in a boarding house with a limited food allowance. | Newly employed professional living alone with little time to cook. |
| Needs | Affordable, nutritious meals; efficient grocery spending; consideration of peanut allergies. | Quick meal planning, reminders to drink water, and fewer discarded ingredients. |
| Challenges | Often buys ingredients already available at home and struggles to find affordable meal ideas. | Busy schedule, forgets refrigerator contents, and frequently discards vegetables. |
| Expectations | Clear visibility of the remaining weekly budget and an organized grocery list. | A concise interface, few interaction steps, and low-stock warnings. |

## 5. Scope

### 5.1 In Scope

- Flutter mobile application using Material Design 3.
- Temporary data based on local mock data and simple state management with `setState()`.
- Responsive layouts for phones and tablets.
- Quick Log: daily logging directly from Home and the Quick Log button without switching menus.
- Lightweight gamification: daily streaks and eight achievement badges.
- Lightweight on-device persistence using `shared_preferences`, if time permits.

### 5.2 Out of Scope

- Backend and server-side database (PostgreSQL), recorded as possible future development outside the course.
- Login, user accounts, and synchronization across devices.
- Reminder notifications, receipt or camera scanning, and AI-generated recipes.
- Medical nutrition calculations. Calorie values are estimates and are not medical advice.

## 6. Functional Requirements

Priority: **M** = Must-have (required and tested in Week 15); **S** = Should-have (implemented if time permits).

English names below describe the functions. In-app product copy remains Indonesian.

| ID | Requirement | Priority | Owner |
|---|---|---|---|
| FR-01 | Welcome screen and three-slide onboarding (`PageView` with an indicator) explaining the purpose and SDG 3 alignment. | M | Louis |
| FR-02 | Main navigation: `NavigationBar` on phones and `NavigationRail` on tablets. | M | Louis |
| FR-03 | Light and dark Material Design 3 themes using `ColorScheme.fromSeed`. | M | Louis |
| FR-04 | Home: budget summary card showing the amount used, remaining budget, and status. | M | Louis |
| FR-05 | Home: summaries of today's meals and water intake. | M | Louis |
| FR-06 | Home: swipeable Health Tip cards. | S | Louis |
| FR-07 | Weekly Insights page with a simple widget-based bar chart, without an additional package. | S | Gilbert |
| FR-08 | Meal list with category filters (`ChoiceChip`): Breakfast, Lunch, Dinner, Budget-Friendly, and High Protein. | M | Jessica |
| FR-09 | Daily Meal Planner covering Monday–Sunday with three meal slots per day. | M | Jessica |
| FR-10 | Add and remove meals from the plan through a bottom sheet. | M | Jessica |
| FR-11 | Meal Detail: image, ingredients, price, calories, cooking time, and brief preparation steps. | M | Jessica |
| FR-12 | Allergy warnings on meal cards and meal details based on Profile data. | M | Jessica |
| FR-13 | Total weekly plan cost and a status showing whether it is under, within, or over budget. | M | Jessica |
| FR-14 | Grocery List: checkable items and the total estimated cost. | M | Gilbert |
| FR-15 | Add grocery items through an inline input field above the list by typing and pressing Enter, without a dialog or page change. | M | Gilbert |
| FR-16 | Swipe to delete an item (`Dismissible`) with an undo option (`SnackBar`). | M | Gilbert |
| FR-17 | A Move to Pantry button for purchased items. | M | Gilbert |
| FR-18 | Pantry: inventory grouped by category. | M | Gilbert |
| FR-19 | Low-stock indicators using `LinearProgressIndicator` and labels. | M | Gilbert |
| FR-20 | Expiry-status badges: Safe, Expiring Soon, and Expired. | M | Gilbert |
| FR-21 | Adjust stock quantities directly in the row using + and − stepper buttons. | S | Gilbert |
| FR-22 | Water Tracker: target progress and +150 / +250 / +500 ml buttons. | M | Edbert |
| FR-23 | Today's water-intake history and target-achieved status. | M | Edbert |
| FR-24 | Food Waste: entry form with item, portion, reason, and estimated Rupiah value. | M | Edbert |
| FR-25 | Food-waste history and total estimated financial loss for the current month. | M | Edbert |
| FR-26 | Profile: weekly budget and water target controls using `Slider`. | M | Edbert |
| FR-27 | Profile: allergies and food preferences using `FilterChip`. | M | Edbert |
| FR-28 | Profile: dark-mode switch and Reset Demo Data button. | M | Edbert |
| FR-29 | Local persistence using `shared_preferences` for budget, water intake, grocery checkmarks, streaks, and badges. Initial demo data includes a sample five-day streak. | S | Louis |
| FR-30 | Quick Log button (Extended FAB) on all main tabs, opening a bottom sheet with Water, Meal, and Food Waste actions. | M | Louis |
| FR-31 | One-tap water logging (+150 / +250 / +500 ml) directly from the Home water card and Quick Log. | M | Edbert |
| FR-32 | Meal logging: a Mark as Eaten checkbox on today's meals in Home and `MealCard`. | M | Jessica |
| FR-33 | Quick food-waste logging: select an item from chips populated from Pantry or recent meals, choose a portion (a little / half / all), and automatically populate the estimated cost; other fields are optional. | M | Edbert |
| FR-34 | A Nothing Was Wasted Today button that counts as a daily record. | M | Edbert |
| FR-35 | All logging actions provide `SnackBar` feedback with an Undo button. | M | All members |
| FR-36 | Daily streak: consecutive days with at least one record, displayed as a Home card. | M | Louis |
| FR-37 | A badge system with eight badges and unlock rules based on existing data. | M | Edbert |
| FR-38 | Achievements page: a grid of unlocked/locked badges with progress, accessible from Profile and the streak card. | M | Edbert |
| FR-39 | A celebration when a badge is unlocked, using a dialog or lightweight animation. | S | Edbert |
| FR-40 | A one-day grace period to prevent an immediate streak reset (streak freeze). | S | Louis |

> **Technical note:** Since state management uses only `setState()`, data shared across pages—budget, meal plans, pantry, water intake, and allergies—is stored in one parent widget (`MainNavigation`) and passed to child pages through constructors together with callbacks. This approach was agreed upon from the outset to prevent duplicate state across pages. Shared feature data belongs to `_MainNavigationState`; app-level theme state remains in the app shell.

### 6.1 Quick Logging Principles

- **No more than two taps** per entry, completed in under ten seconds.
- **No menu switching:** water and meal actions are available on Home, while Quick Log is available across all tabs.
- **Convenient defaults:** remember the last water amount, populate estimated prices from Pantry data, and use portion chips instead of typed input.
- **Minimal fields:** only one required input per entry, with the remaining fields optional.
- **Easy reversal:** every entry can be undone through a `SnackBar`, reducing concern about accidental taps.
- **No nested dialogs:** use a single-screen bottom sheet and inline input rather than layered dialogs.

### 6.2 Gamification: Streaks and Badges

A streak counts consecutive days with at least one water, meal, shopping, or food-waste record. Badges are unlocked using existing data, so users do not need to provide additional input.

| Badge | Unlock condition | Data source |
|---|---|---|
| First Step | Create the first record of any type. | Daily records |
| 3-Day Streak | Log activity on three consecutive days. | Streak |
| 7-Day Streak | Log activity on seven consecutive days. | Streak |
| Hydration Hero | Reach the water target on three days. | Water Tracker |
| Skilled Planner | Fill all meal slots for one full week. | Meal Planner |
| Budget Protected | Keep the total weekly plan cost within budget. | Budget |
| Anti-Waste Hero | Mark Nothing Was Wasted for seven consecutive days. | Food Waste |
| Smart Shopper | Check all grocery items and move them to Pantry. | Grocery and Pantry |

**Design note:** Gamification should be friendly, with no blaming language when a streak ends. The optional one-day grace period (FR-40) is intended to support motivation. These features build on existing data, which is expected to limit their effect on the development schedule.

## 7. Screen Flow and Navigation

Entry flow: Welcome/Onboarding, followed by the main navigation shell with five tabs.

| Tab | Screen | Child screens or interactions |
|---|---|---|
| 1. Home | Home: water card, today's meals, and streak card. | Weekly Insights; Achievements by tapping the streak card. |
| 2. Meals | Meal Planner. | Meal Detail (`Navigator.push`); Add Meal bottom sheet. |
| 3. Shopping | Grocery List and Pantry, presented as two tabs within one screen. | Add Item dialog. |
| 4. Water | Water Tracker and Food Waste, presented as two tabs. | Food Waste entry form. |
| 5. Profile | Profile. | Achievements (badges and streaks); allergy and preference settings. |
| All tabs | Quick Log button (Extended FAB). | Bottom sheet: Water, Meal, and Food Waste. |

Total: approximately 14–15 screens and sub-screens: Welcome, Onboarding, Home, Insights, Meal Planner, Meal Detail, Add Meal, Grocery, Pantry, Water, Food Waste, Quick Log, Profile, and Achievements.

**Responsive behavior:** Compact screens below 600 dp use `NavigationBar` and a single-column layout. Medium screens from 600–839 dp use `NavigationRail` and a two-column `GridView`. Expanded screens at 840 dp and above use `NavigationRail` and a two-pane layout, such as a meal list on the left and details on the right.

## 8. Non-Functional Requirements

| Aspect | Requirement |
|---|---|
| Design | Consistent Material Design 3: a seed-based color scheme, `TextTheme` typography, and Card, Chip, NavigationBar, and FilledButton components. |
| Responsiveness | No overflow at widths from 360 dp to 1024 dp; tested on phone and tablet emulators. |
| Robustness | Validate empty input, negative values, and a zero budget without crashing. |
| Empty states | Every list provides an informative empty state. |
| Accessibility | Adequate text contrast, touch targets of at least 48 dp, and labels or tooltips for icons. |
| Code quality | Consistent Dart naming, no duplicated UI, reusable widgets for repeated elements, and clean `flutter analyze` results. |
| Self-contained operation | Runs from a release APK or web version without additional configuration. |
| Quick logging | Each daily entry takes no more than two taps and under ten seconds, without switching tabs, and supports Undo. |
| Initial data | Realistic Indonesian-language mock data with prices in Rupiah and local ingredients such as tempeh, tofu, eggs, and vegetables. |

## 9. Architecture and Project Structure

### 9.1 Folder Structure

| Path | Contents |
|---|---|
| Project root | `smartbites/` (`budget_bites`) |
| `assets/images/` | `logo.png`, `chickpea_bowl.png`, `vegetable_toast.png`, `oatmeal.png`, and other images. |
| `assets/icons/` | `water_drop.png`. |
| `lib/` | `main.dart`, `app.dart`. |
| `lib/models/` | `meal.dart`, `grocery_item.dart`, `pantry_item.dart`, `water_record.dart`, `waste_record.dart`, `user_profile.dart`, `daily_log.dart`, `achievement.dart`. |
| `lib/data/` | `mock_data.dart`. |
| `lib/screens/` | Welcome, onboarding, home, insight, meal plan, meal detail, grocery, pantry, water tracker, food waste, profile, and achievements screens. |
| `lib/widgets/` | `app_logo`, `budget_card`, `meal_card`, `grocery_item_tile`, `pantry_item_tile`, `water_progress_card`, `waste_item_tile`, `section_title`, `main_navigation`, `responsive_layout`, `quick_log_sheet`, `streak_card`, `badge_tile`. |
| `lib/theme/` | `app_theme.dart`. |
| `lib/utils/` | `app_colors`, `app_constants`, `responsive_breakpoints`, `badge_rules`. |
| Root files | `pubspec.yaml`, `README.md`. |

### 9.2 Data Models

| Model | Main attributes |
|---|---|
| `Meal` | id, name, category, imageAsset, price, calories, cookTimeMinutes, ingredients, allergens, steps |
| `GroceryItem` | id, name, quantity, unit, price, isChecked |
| `PantryItem` | id, name, category, quantity, minQuantity, unit, expiryDate |
| `WaterRecord` | id, amountMl, time |
| `WasteRecord` | id, itemName, portion, reason, estimatedLoss, date |
| `DailyLog` | date, waterMl, mealsEaten, wasteLogged, noWasteMarked |
| `Achievement` | id, title, description, iconAsset, target, progress, isUnlocked |
| `UserProfile` | weeklyBudget, waterTargetMl, allergies, preferences, darkMode |

### 9.3 Reusable Widgets

| Widget | Function | Used in |
|---|---|---|
| `BudgetCard` | Budget summary and under/within/over-budget status. | Home, Meal Planner |
| `MealCard` | Meal card with image, price, calories, and allergy badge. | Meal Planner, Home |
| `GroceryItemTile` | Grocery row with checkbox and price. | Grocery |
| `PantryItemTile` | Inventory row with stock indicator and expiry badge. | Pantry |
| `WaterProgressCard` | Water-intake progress and add buttons. | Home, Water Tracker |
| `WasteItemTile` | Food-waste history row. | Food Waste |
| `SectionTitle`, `AppLogo` | Section headings and application logo. | All screens |
| `ResponsiveLayout` | Select a layout based on screen width. | All main screens |
| `QuickLogSheet` | Quick Log bottom sheet for Water, Meal, and Food Waste. | All tabs through the FAB |
| `StreakCard` | Streak length and progress toward a badge. | Home, Achievements |
| `BadgeTile` | Unlocked or locked badge with progress. | Achievements |

## 10. Mapping to Course Sessions 1–7

| Topic | Application in SmartBites |
|---|---|
| Basic widgets | Text, Icon, Image.asset, CircleAvatar, Card, Chip, Button, TextField, Slider, Switch. |
| Single-child layout | Container, Padding, Center, Align, SizedBox, Expanded. |
| Multi-child layout | Row, Column, ListView, GridView, Stack, Wrap. |
| Material Design 3 | `ColorScheme.fromSeed`, `TextTheme`, NavigationBar/Rail, light and dark themes. |
| Reusable widgets | The twelve widgets in Section 9.3 used as repeated components. |
| Assets | Logo, meal photos, and icons in `assets/images` and `assets/icons`. |
| Responsive UI | `LayoutBuilder`, `MediaQuery`, 600/840 dp breakpoints, adaptive grids, and two-pane layouts. |

## 11. Usability Testing Plan (Week 15)

**Participants:** At least five people, ideally five to eight, outside the project team who match the target audience. Record age, occupation, and shopping and cooking habits.

| Code | Task scenario | Related features |
|---|---|---|
| T1 | Set a weekly budget of Rp 300,000 and a peanut allergy. | Profile |
| T2 | Add a breakfast meal for Monday and view its calories. | Meal Planner, Meal Detail |
| T3 | Find the ingredients that need to be purchased and check two items. | Grocery |
| T4 | Find a Pantry ingredient that is running low. | Pantry |
| T5 | From Home, log 500 ml of water without changing screens and check the target. | Home, Quick Log |
| T6 | Log one discarded food item using Quick Log. | Quick Log, Food Waste |
| T7 | View your streak and find one locked badge. | Streak, Achievements |

| Metric | Measurement method | Target |
|---|---|---|
| Success rate | Percentage of tasks completed without assistance. | At least 80%. |
| Time on task | Stopwatch measurement for each task in seconds. | Record and compare across tasks. |
| Error rate | Number of incorrect taps or navigation paths per task. | Average below one per task. |
| Tap count | Taps required to complete daily logging in T5 and T6. | Two or fewer. |
| SUS | Ten standard questions administered through a form. | At least 68. |
| Qualitative feedback | Think-aloud observations and two to three closing questions. | Findings accompanied by identified root causes. |

**Testing evidence:** Session photos or screen recordings with participant permission, observation sheets, SUS responses, and a short consent form.

## 12. Peer Testing Readiness (Final Assessment)

- **Distribution:** A release APK and a web version (`flutter build web`) as a fallback for non-Android testers.
- **Tester package:** Application description, installation instructions, test tasks, devices already tested, and team contact details.
- **Independent use:** Realistic initial data, brief onboarding, a Reset Demo Data button, and no nonfunctional buttons.
- **As evaluators:** Prepare evaluation instruments for other projects: a functionality checklist, Material Design 3 and responsiveness assessments, SUS, and bug-report fields covering steps, expected results, actual results, and screenshots.

## 13. Task Allocation and Schedule

Tasks are distributed to balance the workload and give each member experience with different layouts, enabling everyone to explain their code during the demonstration. The project is in Week 3 at the time this document is prepared.

### 13.1 Responsibilities by Member

| Member | Scope | Main layouts |
|---|---|---|
| Louis | M3 theme, `app.dart`, main navigation and parent state, `responsive_layout`, Welcome and Onboarding, Home, `BudgetCard`, `SectionTitle`, `AppLogo`, `QuickLogSheet` and FAB, `StreakCard` and streak logic, `DailyLog` model, local persistence. | Stack, GridView, LayoutBuilder |
| Jessica | Meal model and mock data, Meal Planner, Meal Detail, `MealCard`, filter chips, Add Meal bottom sheet, allergy warnings, Mark as Eaten checkboxes, Quick Log Meal action, demo video coordination. | ListView, Stack, Wrap |
| Gilbert | Grocery and Pantry models, Grocery List with inline input, Pantry with steppers, `GroceryItemTile`, `PantryItemTile`, Grocery-to-Pantry flow, stock and expiry badges, Insights, usability testing script. | ListView, ListTile, Dismissible |
| Edbert | Water, Waste, UserProfile, and Achievement models, Water Tracker, quick Food Waste logging, Profile, `WaterProgressCard`, `WasteItemTile`, Reset Data, badge system and Achievements page, `BadgeTile`. | Column, Row, Slider, GridView |

### 13.2 Schedule by Block

**Louis**

| Block | Tasks |
|---|---|
| Block 1: Week 3, remaining time | GitHub repository and branches; folder structure and `app_theme`; `MainNavigation` scaffold and parent state (`DailyLog`); `responsive_layout`; finalize PRD v1.1. |
| Block 2: Weeks 4–6 | Welcome and Onboarding; Home with `BudgetCard`; Quick Log button and `QuickLogSheet` scaffold; `StreakCard` and streak logic; parent-state integration. |
| Block 3: Weeks 7–8 | Cross-feature budget integration; tablet testing for Home; optional Health Tip and streak freeze; architecture section of the report. |

**Jessica**

| Block | Tasks |
|---|---|
| Block 1: Week 3, remaining time | Meal wireframes; `Meal` model and mock data with at least ten meals; Meal Planner screen scaffold. |
| Block 2: Weeks 4–6 | Meal Planner and filter chips; Meal Detail using Stack; Add Meal bottom sheet; allergy warnings; Mark as Eaten checkboxes in `MealCard` and Home. |
| Block 3: Weeks 7–8 | Budget totals and status; tablet two-pane layout; Quick Log Meal action; Meal bug fixes; demo video coordination; design and Meal sections of the report. |

**Gilbert**

| Block | Tasks |
|---|---|
| Block 1: Week 3, remaining time | Grocery and Pantry wireframes; models and mock data; Grocery and Pantry screen scaffolds. |
| Block 2: Weeks 4–6 | Grocery checkboxes, totals, and inline input; Dismissible and SnackBar Undo; Pantry categories, stock indicators, expiry badges, and steppers; Grocery-to-Pantry flow. |
| Block 3: Weeks 7–8 | Optional Insights; small-screen and tablet testing; input validation; usability testing script; testing section of the report. |

**Edbert**

| Block | Tasks |
|---|---|
| Block 1: Week 3, remaining time | Water, Waste, Profile, and Achievements wireframes; `Water`, `Waste`, `UserProfile`, and `Achievement` models; design eight badges and unlock rules; screen scaffolds. |
| Block 2: Weeks 4–6 | Water Tracker and quick +ml buttons; quick Food Waste logging with chips, portions, and automatic prices; Nothing Was Wasted button; Profile with Slider, chips, and Switch; Reset Demo Data. |
| Block 3: Weeks 7–8 | Badge system (`badge_rules`); Achievements page and `BadgeTile`; optional badge celebrations; responsive testing; data and Profile sections of the report. |

### 13.3 Evidence of Contributions for the Lecturer

- An individual AI/vibecoding log recording prompts, outputs, modifications, and bug fixes for the Session 2 report.
- A task-allocation table in the report identifying the files owned by each member.
- Every member is prepared to explain and modify their own code during the demonstration.

### 13.4 Post-Midterm Schedule

| Period | Activities |
|---|---|
| Weeks 9–13 | Complete Should-have features, polish the UI, conduct internal testing, and prepare release builds. |
| Week 14 | Recruit participants and prepare usability testing scripts and forms. |
| Week 15 | Conduct usability testing with external users, prepare the report, and present through Teams. |
| After Week 15 | Make improvements based on findings, prepare final APK and web builds, and assemble the tester package. |
| Final Assessment | Demonstration, peer testing by other groups, and evaluation of other groups' projects. |

## 14. Use of AI/Vibecoding

AI is used as an aid rather than a substitute for understanding. Team rules:

1. Record important prompts and outputs in each member's AI log.
2. Read, run, and test AI-generated code before merging it.
3. Each member independently modifies at least one part of the code, such as colors, layout, or logic, and records the change.
4. Document bugs and layout overflows together with their fixes.
5. Do not merge pull requests until `flutter analyze` is clean and the affected screens have been tested on phones and tablets.

## 15. Risks and Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Uneven workload across members | Some members fall behind. | Review progress weekly; Louis completes the foundation first. |
| Duplicate state across pages | Inconsistent data. | Centralize shared state in `MainNavigation` from the outset. |
| Overflow on small screens or tablets | Lower responsiveness assessment. | Regularly test multiple emulator sizes for each pull request. |
| APK build failure near the deadline | Peer testing is delayed. | Try `flutter build apk` from Week 4 and repeat it in each block. |
| Difficulty recruiting external participants | Insufficient usability data. | Begin recruitment in Weeks 12–13 and identify backup participants. |
| AI-generated code is not understood | Members cannot explain it during the demonstration. | Hold peer code-explanation sessions before the demonstration. |
| Scope growth from Quick Log and gamification | Core features remain incomplete. | Use simple badge rules based on existing data; keep celebrations and streak freeze optional. |
| Gamification feels pressuring | Users stop using the application. | Use friendly, non-blaming language and a one-day grace period. |
| Merge conflicts | Development time is lost. | Use one branch per member and allocate file ownership. |

## 16. Definition of Done

A feature is considered complete when:

- It works without errors and `flutter analyze` is clean.
- It displays correctly on compact and medium/expanded screens without overflow.
- It uses the existing Material Design 3 theme and reusable widgets.
- Invalid input and empty lists are handled.
- It has been reviewed through a pull request, and its owner can explain the code.
