# SmartBites Contribution Rules

Active guidance for every AI coding agent, including Claude, Codex, and delegated agents. Read the root `AGENTS.md` first, then this file in full. 

These rules govern authorized work (they do not authorize a contribution or remote action by themselves).

## 1. Preparation

Before editing:

1. Read the complete task and applicable agent instructions.
2. Inspect Git state from the repository root:

   ```bash
   git status --short
   git branch --show-current
   git log -1 --oneline
   git diff
   ```

3. Identify existing modifications and deletions. Never reset, overwrite, stage, or restore unrelated work.
4. Check the README ownership map. Identify affected callers and owners for shared-contract changes; report cross-owner impact. Do not message teammates without authorization.
5. Apply the root Graphify-first policy before broad source browsing. Then inspect affected source, tests, imports, state ownership, dependencies, assets, and relevant CI. Verify graph findings with targeted searches and direct source reads.
6. Read relevant PRD sections, integration contracts, and UI references. Distinguish implemented behavior, requirements, proposals, and unresolved questions.
7. Establish the smallest coherent change and its validation plan. State material assumptions and resolve essential unknowns before dependent implementation.

Start with a read-only audit when scope is unclear. Before implementation, establish the observed behavior, intended behavior, acceptance criteria, affected owners/callers, and validation plan. Briefly explain material risks or assumptions to the user; do not require a separate approval for routine, reversible work already authorized by the task.

## 2. Graphify operating procedure

The root `AGENTS.md` defines when mapping is required. This section explains how to obtain useful evidence without treating the map as complete or authoritative.

### Check availability and version

For mapping-required work, check the CLI from the repository root:

```bash
graphify --version
graphify --help
```

Use command-specific help when necessary, for example `graphify extract --help` or `graphify update --help`. Check supported flags rather than repeating a command that the installed release rejects. The official Python package is `graphifyy` (double `y`); its executable is `graphify`. It is development tooling, not a Flutter runtime dependency.

If installation is needed, use one supported isolated installer in an authorized environment:

```bash
uv tool install graphifyy
```

Alternatively:

```bash
pipx install graphifyy
```

Do not run both installers. Installation instructions are not evidence that the tool is installed. Respect environment approval requirements; do not alter global agent configuration or install assistant skills as a side effect. Direct CLI mapping does not require a `/graphify` assistant integration.

Official references: [repository and installation](https://github.com/Graphify-Labs/graphify), [CLI reference](https://docs.graphify.com/reference/overview), [extraction](https://docs.graphify.com/reference/extract), and [incremental updates](https://docs.graphify.com/guides/incremental-updates). Consult them when local help does not resolve a version mismatch.

### Establish the correct graph

1. Confirm the working directory is the SmartBites repository root. Use the graph for this checkout, not another branch or worktree.
2. Check for `graphify-out/graph.json`. If absent, run `graphify extract . --code-only` as specified in `AGENTS.md`.
3. Inspect the extraction summary, warnings, and a focused query. Confirm relevant `lib/` and `test/` files are represented. Do not infer success from the presence of a JSON file alone.
4. Respect ignore rules. Keep build outputs, caches, dependencies, generated files, and private configuration out of the scan. Do not use `--no-gitignore` or `--force` to hide unexplained extraction failures or replace a larger valid graph with an incomplete one.
5. Keep each checkout's graph local to that checkout. Do not point multiple worktrees at one shared writable output directory.

The code-only map is not a full index of product requirements or design references. Read the applicable documents directly. Confirm that the installed release maps Dart constructs adequately; the [upstream Dart extractor](https://github.com/Graphify-Labs/graphify/blob/v8/graphify/extractors/dart.py) inspected when writing this policy uses regular expressions, so AST-level completeness must not be assumed. Flutter callback wiring and dynamic behavior still need source and runtime verification.

### Ask questions that narrow the task

Use concrete SmartBites symbols and responsibilities. Examples, not guaranteed graph results:

```bash
graphify query "_MainNavigationState water records callbacks" --graph graphify-out/graph.json
graphify query "UserProfile budget HomeScreen" --graph graphify-out/graph.json
graphify explain "_MainNavigationState" --graph graphify-out/graph.json
graphify path "MainNavigation" "HomeScreen" --graph graphify-out/graph.json
```

Use labels or precise IDs returned by your actual graph to resolve ambiguity. Retry an empty natural-language query with a concrete symbol before expanding the search. `path` follows stored direction by default; an absent path does not prove that two components are independent. Consult [query](https://docs.graphify.com/reference/query), [path](https://docs.graphify.com/reference/path), and [explain](https://docs.graphify.com/reference/explain) semantics when interpreting results.

For each relevant result:

1. Identify the source file, symbol, relation, and available provenance. Distinguish directly extracted relationships from inferred ones.
2. Open current source at the returned location; verify the symbol still exists and the relationship is accurate.
3. Trace constructor arguments, callbacks, state mutations, and derived values. Inspect callers and affected tests before changing shared contracts.
4. Compare technical dependencies with README ownership. Graph connectivity does not establish who owns a feature.
5. Summarize the affected path in plain language, for example: user action -> screen callback -> shared state mutation -> derived summary -> rebuilt UI. This is a verification checklist, not a claim that every step appears in the graph.

Use targeted `rg` searches after graph orientation to fill gaps. Never treat graph centrality as a mandate to refactor, missing nodes as unused code, or a connected path as proof of runtime correctness.

### Missing, stale, or incomplete mapping

- If Graphify is missing or fails, report the exact limitation and try the relevant help or supported setup within the task's authorization. Do not silently mark the Graphify requirement as satisfied.
- If mapping remains unavailable or coverage is insufficient, use a disclosed fallback: inspect the known entry point, imports, constructors, callbacks, callers, and tests with targeted searches. Continue only work whose impact can be established from that evidence. If essential relationships remain unknown, report the blocker before changing them.
- A stale graph may guide orientation, but verify every affected relationship against current source. Schedule refresh after required validation; do not refresh over failing changes just to obtain a newer timestamp.
- Do not enable semantic backends, cloud services, or external API keys to compensate for missing source relationships without explicit authorization for that processing.
- Record what was mapped, what was verified directly, and which limitations remain. Do not claim that a fallback or a successful Graphify command proves full project coverage.

### Refresh and artifact handling

After required checks pass, run `graphify update .` when the task changes source relationships as defined in `AGENTS.md`. Re-run the affected query or explanation and inspect the summary to confirm the changed symbols/relations are represented. If refresh fails, report source validation and mapping failure separately; do not claim mapping is current.

Skip refresh for documentation, templates, formatting, comments, translations, and housekeeping that do not change source relationships. Do not install hooks/watchers that refresh before validation. Do not run graph generation merely to validate an instruction-only edit.

Keep `.codex/` and `graphify-out/` local/untracked unless explicitly adopted for version control, even when upstream suggests committing graphs. For an authorized setup, use an approved `.gitignore` change or local Git exclusion; documentation alone does not configure exclusions. Never stage generated output or run `git rm --cached` against tracked configuration without authorization. Check `git status --short` and `git diff --cached --name-only` before an authorized commit.

## 3. Scope and engineering

- Implement requested behavior; avoid unrelated refactoring, TODO fixes, formatting, and speculative infrastructure.
- Reuse existing models, widgets, formatters, tokens, and dependencies before introducing alternatives.
- Prefer simple, explicit code, composition, type safety, and clear ownership. Extract abstractions for demonstrated responsibility or stable duplication, not arbitrary file-count targets.
- Report separate issues. Fix them only when they block the task or pose an immediate correctness, security, privacy, or data-integrity problem.
- Do not add packages, upgrade toolchains, or rewrite configuration merely to make implementation easier.
- Do not manually edit generated files or commit local caches and tool output.

## 4. Flutter architecture and code

- Follow Dart null safety, explicit types, existing conventions, and appropriate `const` constructors and literals.
- Keep domain data in models and data files rather than widget `build()` methods.
- Preserve `_MainNavigationState` ownership of shared feature data. Pass values down through constructors and mutations back through typed callbacks.
- Keep transient widget state local and theme state in the app shell. Avoid duplicate shared mutable state or introducing another state-management package without an explicit architectural task.
- Verify `docs/integration_contract.md` against constructors and callers before changing screen contracts. Update affected callers and documentation together.
- Keep widgets cohesive. Separate substantial UI and business logic when it clarifies responsibility; avoid ceremonial wrappers.
- Dispose owned controllers, listeners, focus nodes, and similar resources. Check mounted state after asynchronous gaps where needed; never use asynchronous `setState()` callbacks.
- Preserve supported undo behavior. Keep summaries, streaks, badges, and budget totals consistent with underlying records.
- Document public APIs and non-obvious contracts when useful; do not add comments that merely repeat code.

## 5. Data and product integrity

- Preserve local mock data and avoid mutating shared fixtures unintentionally. Keep tests independent of execution order, network responses, and uncontrolled time.
- Check date boundaries, currency units, quantities, and hydration units before changing calculations. Reuse shared formatting and business-rule helpers.
- Validate invalid, empty, zero, negative, and boundary inputs where relevant; preserve model constraints and derived totals.
- A declared dependency is not proof of an integration. Do not describe `shared_preferences` as working persistence unless runtime implementation and verification support the claim.
- Do not silently introduce login, payments, server APIs, external nutrition services, notifications, or synchronization.
- Distinguish sample values, estimates, hypotheses, requirements, and verified outcomes. Never fabricate research results, health benefits, savings, environmental impact, or regulatory claims.
- Pantry expiry reminders do not certify food safety. Do not invent storage, allergen, shelf-life, or medical guidance.

## 6. UI and accessibility

- Preserve Material Design 3, Indonesian copy, branding, and shared theme tokens unless explicitly asked to change them.
- Consult `design.md` and relevant HTML or screenshot references. Verify fonts/assets in `pubspec.yaml`; references alone do not prove fonts are bundled.
- Reuse existing responsive breakpoints: compact below 600 logical pixels, medium from 600 to below 840, expanded from 840 upward. Check current definitions before changing them.
- Verify narrow phones, tablet widths, text scaling, keyboard insets, safe areas, scrolling, and overflow for affected UI.
- Maintain readable contrast, meaningful semantics, appropriate tap targets, and usable focus behavior. Check loading, empty, error, and disabled states where relevant.
- Use platform insets instead of drawing operating-system status or gesture bars as Flutter widgets.
- Compare actual Flutter output with supplied references before claiming visual parity. Report unavailable emulator, device, or screenshot verification.

## 7. Security, privacy, and licensing

- Never commit secrets, real environment values, API tokens, signing keys, keystores, credentials, personal data, or sensitive logs.
- Use generated or sanitized fixtures. Minimize collection and logging of user information; client-side checks are not authoritative backend authorization.
- Do not bypass TLS, weaken validation, or log secrets for convenience.
- Check `LICENSE` and third-party redistribution terms before copying code, fonts, images, or reference material. Preserve required attribution.
- Existing Android release configuration uses debug signing. Do not describe APKs as production-signed or store-ready without verifying signing and packaging.

## 8. Validation by change scope

Run commands from the repository root, where `pubspec.yaml` lives. Inspect current configuration before assuming tools or checks are available.

### Flutter or Dart changes

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
git diff --check
```

Run focused tests during iteration and the full suite before handoff. Add meaningful regression tests for changed behavior when practical; avoid tests that only mirror implementation. Format only affected files when fixing formatting, and report unrelated baseline failures instead of reformatting the repository.

For UI changes, also exercise affected interactions on a compact phone and a medium or expanded layout when an emulator or device is available. Widget tests complement runtime inspection.

### Android packaging or platform changes

In addition to applicable analysis and tests, run the build modes affected by the task:

```bash
flutter build apk --debug
flutter build apk --release
```

Verify signing implications for release changes. A successful build does not prove production signing.

### Documentation-only changes

Run `git diff --check` for affected files and verify local paths, Markdown links, commands, and technical claims. Do not run the Flutter suite solely for prose changes.

### Workflow or dependency changes

- For CI changes, validate YAML and GitHub Actions syntax with an appropriate available validator and run affected checks locally where possible. YAML parsing alone does not validate action inputs or expressions.
- For dependency changes, resolve dependencies successfully, then run formatting, analysis, tests, and affected platform builds.
- Check analyzer configuration alongside declared dependencies. Sections naming Dart Code Linter or Dartrics do not prove their executables are installed or enforced by CI. Report mismatches rather than inventing a working quality gate.
- Do not suppress warnings, remove rules, skip tests, or weaken CI to obtain passing checks. Investigate incompatibilities and explain proposed configuration changes.

Always distinguish passed checks, failed checks, checks not run, and environmental blockers. Do not claim full validation when required checks have not passed.

### Failure handling and order of operations

Use this sequence: inspect and map -> verify source and contracts -> implement -> run required checks -> review the diff -> refresh Graphify when required -> report. Commit, push, and PR work are separate actions requiring authorization.

If a check fails, inspect its exact output and distinguish a regression from an existing failure or environment problem. Fix task-related causes and rerun relevant checks; repeat broader checks when the fix can affect them. Do not describe implementation as fully validated while required checks remain failing. A graph refresh is never a substitute for formatting, analysis, tests, builds, or manual UI checks.

## 9. Git, commits, and pull requests

- Follow the README member-branch convention: `feature/louis`, `feature/jesseca`, `feature/gilbert`, and `feature/edbert`. Inspect the current branch and local changes before considering a switch; do not invent a member identity or move work unnecessarily.
- Keep one concern per change. Fetch the remote base when the authorized task needs current remote state, not before every local edit.
- Do not stage, commit, amend, push, open a PR, request reviewers, merge, delete branches, or rewrite history without explicit user authorization for that action.
- Never commit directly to `main`. Merge through a PR with required checks passing.
- Never discard another contributor's work or clean up unknown files. Explain scope and recovery before authorized destructive operations.
- Do not force-push without explicit authorization. Use `--force-with-lease` for an authorized history rewrite.

When a commit is requested, use a truthful Conventional Commit message:

```text
<type>(<optional-scope>): <imperative description>
```

Examples: `fix(pantry): correct expiry date comparison`, `docs: clarify agent contribution rules`, `ci(build): validate Android packaging`. Do not label documentation-only work as a feature.

Before committing, inspect the full and staged diffs, run `git diff --check` and `git diff --cached --check`, verify required checks passed, and confirm only authorized files are staged. Exclude caches, unrelated generated artifacts, and private files.

When a PR is requested, read the current repository template if present and retain its sections. If absent, report it and describe the problem, resulting behavior, affected areas, validation, limitations, and relevant UI evidence. Never check boxes for commands that did not pass.

After an authorized push, inspect required CI results when available. A push does not prove CI passed. Investigate the failing step, fix the cause within scope, rerun relevant checks, and push fixes only within the user's authorization. Do not merge with failing required CI.

## 10. Final review and reporting

Review every changed line and final Git status. Confirm focused scope, accurate documentation, valid reference paths, and no secrets or unsupported claims.

Report concisely:

- Current branch, implemented behavior, and files changed.
- Important assumptions, discrepancies, and design decisions.
- Validation commands and observed results, including failures, skipped checks, and blockers.
- Graphify queries/extraction/refresh performed and relevant findings, or the reason mapping or refresh was skipped. Disclose any targeted-source fallback and incomplete Dart coverage.
- Manual or visual verification and relevant remaining compatibility, security, privacy, or product limitations.
- Commit hash, push result, and PR link only when authorized and performed.

Do not claim completion while mandatory task acceptance criteria remain unmet. Separate completed implementation, incomplete verification, and optional follow-up work.
