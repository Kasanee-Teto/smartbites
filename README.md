# SmartBites

## About the Project

Everyday food decisions involve several connected questions: what to eat, how much to spend, which ingredients are available, and what needs to be purchased. SmartBites offers information easier for management and review.

This mobile application provides a shared experience for planning meals, checking budget information, managing grocery and pantry lists, and recording routine activities. 

Lightweight streaks and achievements support engagement with the application.

### Sustainability Alignment

| Goal | Intended connection to SmartBites |
| --- | --- |
| [SDG 3: Good Health and Well-Being](https://sdgs.un.org/goals/goal3) | Support awareness of everyday meal choices and hydration through planning and logging. |
| [SDG target 12](https://sdgs.un.org/goals/goal12) | Support awareness of consumer food waste through pantry visibility, grocery planning, and food-waste records. |

These connections describe the project's intended direction. They do not establish United Nations endorsement or demonstrate health improvements, actual savings, or measured food-waste reduction.

## Features

The following table describes the project feature scope. Implementation and completion should be checked against the current source code and functional requirements.

| Area | Scope |
| --- | --- |
| Welcome and onboarding | Introduce the application and its planning experience. |
| Home dashboard | Bring budget information, daily activity, and streak information into a common overview. |
| Meal planning | Organize meal plans and view individual meal details. |
| Budget visibility | Present sample food costs and budget information for planning. |
| Grocery list | Manage items needed for shopping and their list status. |
| Pantry tracking | Keep available ingredients and associated item information visible. |
| Water tracker | Record water intake and view progress based on the application's configured values. |
| Food-waste records | Record food waste for later review and awareness. |
| Insights | Present summaries derived from available application data. |
| Profile | Display and manage profile-related information within the local prototype. |
| Achievements and streaks | Provide lightweight recognition for recorded activity. |
| Quick logging and undo | Support frequent actions with short interaction paths and existing undo behavior. |
| Theme and responsive layout | Keep the interface consistent across supported themes and phone/tablet layouts. |

## Tech Stack

| Concern | Project choice |
| --- | --- |
| UI framework | [Flutter](https://flutter.dev/) |
| Programming language | [Dart](https://dart.dev/) |
| UI components and styling | [Material Design for Flutter](https://docs.flutter.dev/ui/design/material) |
| State updates | Flutter `StatefulWidget` and `setState()` |
| Data flow | Constructor parameters and typed callbacks |
| Sample data | `lib/data/mock_data.dart` |
| Static analysis | `flutter analyze` |
| Source control | Git with member branches and pull requests |

Use `pubspec.yaml` as the source of truth for SDK constraints, declared dependencies, and registered assets. 

This README does not prescribe an unverified Flutter or Dart version.

## Project Architecture

SmartBites uses a straightforward widget-based architecture. Shared feature state is lifted to a common owner, while screens and reusable widgets receive the data and callbacks they need.

The structure separates application startup, app-level configuration, shared feature state, feature screens, reusable widgets, data models, and local sample data. It does not require additional state-management frameworks or a backend layer.

### Responsibilities

| Part | Location | Responsibility |
| --- | --- | --- |
| Entry point | `lib/main.dart` | Application startup. |
| App shell | `lib/app.dart` | App-level configuration and ownership of theme state. |
| Shared feature state | `lib/widgets/main_navigation.dart` | `_MainNavigationState` owns data shared across features and coordinates updates. |
| Feature screens | `lib/screens/` | Present feature interfaces and forward user actions through typed callbacks. |
| Reusable UI | `lib/widgets/` | Present cards, tiles, layout helpers, and quick-log interactions. |
| Data models | `lib/models/` | Define the typed objects used by features. |
| Local sample data | `lib/data/mock_data.dart` | Supply mock records for the prototype. |
| Theme definitions | `lib/theme/app_theme.dart` | Keep shared theme definitions consistent. |
| Supporting utilities | `lib/utils/` | Hold shared colors, constants, responsive breakpoints, and badge rules. |

### State Ownership

| State category | Owner | Rule |
| --- | --- | --- |
| Shared feature data | `_MainNavigationState` | Keep one authoritative value for data used by multiple screens. |
| App-level theme state | App shell | Pass theme settings and change callbacks to the UI that needs them. |
| Temporary UI state | Relevant screen, sheet, or widget | Keep transient input and local interaction state close to its UI when no other feature needs it. |
| Mock seed data | `mock_data.dart` as a data source | Use sample data to initialize the experience; keep mutable shared feature state with its designated owner. |

Avoid independently maintained copies of the same shared records in different screens. 

Budget summaries, insights, streaks, and achievements should use the authoritative feature data relevant to them.

### Design and Responsive Layout

- Keep theme definitions in `app_theme.dart` and shared color definitions in `app_colors.dart`.
- Use `responsive_breakpoints.dart` and `responsive_layout.dart` consistently when adapting layouts.
- Verify compact phone layouts and medium/expanded tablet layouts.
- Preserve Indonesian labels, validation messages, empty states, and action feedback.
- Preserve quick routine logging and the existing undo interactions.

Use the repository's breakpoint values as the source of truth; do not introduce competing width thresholds in individual screens without a clear need.

## Project Structure and Ownership

The project groups files by responsibility:

| Directory | Contents |
| --- | --- |
| `lib/data/` | Local mock data shared by the prototype. |
| `lib/models/` | Meal, grocery, pantry, water, waste, profile, activity, and achievement models. |
| `lib/screens/` | Welcome, onboarding, dashboard, and feature-level interfaces. |
| `lib/theme/` | Application theme definitions. |
| `lib/utils/` | Shared constants, colors, responsive breakpoints, and badge rules. |
| `lib/widgets/` | Reusable UI, responsive helpers, navigation, and quick logging. |

### File Ownership and Functional Requirements

`FR` identifies a functional requirement. The mappings below preserve the team's ownership allocation; an FR reference does not by itself confirm implementation or test completion.

| File / Module | Owner | FR Coverage |
| --- | --- | --- |
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
| `lib/models/meal.dart` | Jessica | FR-08, FR-09, FR-11, FR-12 |
| `lib/screens/meal_plan_screen.dart` | Jessica | FR-08..10, FR-13 |
| `lib/screens/meal_detail_screen.dart` | Jessica | FR-11, FR-12 |
| `lib/widgets/meal_card.dart` | Jessica | FR-08, FR-11, FR-12, FR-32 |
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

Coordinate changes to another member's module with its owner. Shared models, constructor contracts, callbacks, constants, and mock data deserve particular attention because other features may depend on them.

## Getting Started

### Prerequisites

- Install the [Flutter SDK](https://docs.flutter.dev/install) with a version compatible with `pubspec.yaml`.
- Install Git if you will clone the repository or contribute changes.
- Configure an emulator or connect a physical device for the target platform.
- Use an editor with Flutter and Dart support, such as Android Studio or Visual Studio Code.

Check your development environment:

```bash
flutter doctor
```

Resolve any reported issues that block your selected target platform.

### Installation

Clone or download this repository, then open its project root: the directory containing `pubspec.yaml`.

Install dependencies:

```bash
flutter pub get
```

### Run Locally

Run static analysis:

```bash
flutter analyze
```

Start an emulator or connect a device, then launch the application:

```bash
flutter run
```

If several devices are available, list them and select one:

```bash
flutter devices
flutter run -d <device-id>
```

Replace `<device-id>` with an identifier returned by `flutter devices`.

### Contribution Workflow

1. Update your local view of the repository and work on your assigned branch.
2. Coordinate changes that affect another owner's files or a shared interface.
3. Keep changes focused on the assigned feature or fix.
4. Run `flutter analyze` and resolve all reported issues.
5. Test the affected flow on a compact phone emulator and medium/expanded tablet emulator layouts.
6. Open a pull request targeting `main` with a clear description and validation results.
7. Merge through the pull-request workflow after the required checks and review.

**Do not commit directly to `main`.** Changes reach `main` through pull requests only.

### Pull Request Description

Include the problem or requirement addressed, the resulting behavior, relevant FR identifiers, and the validation performed. Call out shared model or callback changes so other members can assess integration effects.

Report the actual emulator sizes tested and the actual analysis result. Do not mark a check as passed if it was not run.

## Validation and Testing

### Required Merge Checks

- `flutter analyze` completes with **0 issues**.
- The changed flow has been exercised on a **compact phone emulator**.
- The changed flow has been exercised on **medium and expanded tablet emulator layouts**.

During manual verification, check layout overflow, readable text, reachable actions, navigation, cross-screen state consistency, and the existing undo behavior affected by the change.

### Automated Tests

If automated tests are present, run the relevant suite:

```bash
flutter test
```

## Development Priorities

The current priority is a coherent local planning and routine-tracking experience. The following are quality goals, not verified completion claims:

- [ ] Keep shared records and derived summaries consistent across screens.
- [ ] Make compact, medium, and expanded layouts usable throughout the core flow.
- [ ] Keep frequent logging actions quick and easy to reverse.
- [ ] Improve Indonesian copy, input validation, and empty-state guidance.
- [ ] Check that streak and achievement feedback reflects the relevant records.
- [ ] Document validation evidence for the functional requirements used in the assessment.

Backends, AI services, payments, cloud synchronization, and other major scope expansions are not implied by this list.

## Team

| Member | Primary responsibility |
| --- | --- |
| Louis | App foundation, theme, responsive layout, home, navigation, quick logging, and streak UI. |
| Jessica | Meal models, meal planning, meal details, and meal cards. |
| Gilbert | Grocery and pantry features, related models and tiles, and insights. |
| Edbert | Water tracking, food-waste records, profile, achievements, and badge rules. |
| All members | Shared mock data and feature integration. |