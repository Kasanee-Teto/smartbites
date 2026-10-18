# Repository rules

## Scope and ownership

- Keep each change limited to the requested behavior.
- Read the ownership table in `README.md` before changing a feature. Coordinate edits that cross another owner's area.
- Reuse existing models, widgets, constants, theme values, breakpoints, and mock data before introducing new abstractions.
- Do not overwrite unrelated work or reformat unrelated files.

## Dart and Flutter

- Follow Dart null-safety and Flutter conventions.
- Prefer `const` constructors and literals where possible.
- Keep public declarations typed and give them explicit return types.
- Keep widgets focused and move repeated UI into `lib/widgets/`.
- Keep domain data in models or `lib/data/`, not inside widget build methods.
- Dispose controllers, focus nodes, animation controllers, and other resources created by stateful widgets.
- Avoid adding dependencies or a new state-management package unless the task requires it.
- Do not manually edit generated files.

## UI and behavior

- Preserve the existing Material 3 visual language and Indonesian user-facing copy.
- Use shared theme colors, constants, and responsive breakpoints instead of duplicate literals.
- Check loading, empty, error, overflow, touch-target, and text-scaling states when changing UI.
- Keep mock data deterministic so tests and screenshots remain stable.

## Tests and Git

- Add or update a focused test for a behavior change or regression when practical.
- Run `flutter analyze` and the relevant `flutter test` suites before handoff.
- Work on a descriptive feature branch, following the team's `feature/<name>` convention.
- Merge to `main` through a pull request; do not commit directly to `main`.
