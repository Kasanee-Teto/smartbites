# SmartBites agent instructions

This file is the entry point for coding agents working in this repository. Keep it short; detailed guidance lives in `.agents/`, and task-specific workflows live in `.agents/skills/*/SKILL.md`.

## Start here

Read these files before making changes:

- `.agents/project.md`: app purpose, architecture, and repository layout.
- `.agents/commands.md`: setup, analysis, tests, and run commands.
- `.agents/rules.md`: coding, testing, UI, data, and Git rules.

Read these when the task matches their scope:

- `.agents/skills/flutter-ui/SKILL.md`: Flutter screens, widgets, navigation, responsive layouts, and Material 3 styling.
- `.agents/skills.md`: index of available repository skills.

## Working agreement

- Follow the user's requested scope and make focused changes.
- Preserve the existing Material 3 design, Indonesian product copy, local mock-data approach, and `setState()` state management unless the task explicitly changes them.
- Check the ownership map in `README.md` before editing a feature area.
- Run the relevant validation commands before reporting completion.
- Do not commit directly to `main`.
