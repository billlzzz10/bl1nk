# Repository Guidelines

## Project Structure & Module Organization
- `app/`: client integrations (CLI, VSCode, web, server adapters).
  - `client-desktop`: Windows desktop app (Electron + TypeScript).
- `pkg/`: core Dart/Flutter code (logic, types, UI components, schemas).
- `services/`: infrastructure adapters (e.g., Redis, Qdrant).
- `commands/`: CLI/dev utilities and entrypoints.
- `tests/`: test plans and suites (`unit/`, `integration/`, `e2e/`).
- `doc/` and `README.md`: product and developer docs.
- `scripts/`: workflow/security helpers; prefer running via `node` or task runners.

## Build, Test, and Development Commands
- Node tooling
  - `npm ci` — install JS dependencies.
  - `npm test` — project test hook (may be a placeholder; prefer language‑specific commands below).
- Dart/Flutter modules in `pkg/`
  - `dart format pkg` and `dart analyze pkg` — format and static analysis.
  - `dart test` or `flutter test` — run unit tests when present (`*_test.dart`).
- Python utilities
  - Activate local venv: `source .venv/bin/activate` (if used by a script).

- Electron (Windows desktop) in `app/client-desktop/`
  - `npm install` — install dependencies.
  - `npm run dev` — TypeScript watch + Electron reload. Use `ENABLE_SHARE_UI=true` to unlock Share menu placeholders.
  - `npm run build` then `npm start` — build JS to `dist/` and run app.

## Coding Style & Naming Conventions
- Dart: 2‑space indent; files `snake_case.dart`; classes `PascalCase`; members `camelCase`.
- JS/TS/JSON: 2‑space indent; prefer ESM/CommonJS consistently per file; keep configs minimal.
- Python: 4‑space indent; modules `snake_case.py`.
- Imports: keep relative within module boundaries (e.g., do not jump across top‑level folders).
- Run formatters before PR: `dart format`, `eslint/prettier` if configured.

## Testing Guidelines
- Frameworks: use `dart test`/`flutter test` for Dart; colocate or mirror structure under `tests/`.
- Naming: `*_test.dart` with descriptive names (e.g., `chat_message_service_test.dart`).
- Coverage: target ≥80% for changed lines; include edge cases and failure paths.
- Add `tests/integration/` and `tests/e2e/` for cross‑module or client flows.

## Commit & Pull Request Guidelines
- Use Conventional Commits: `feat(scope): …`, `refactor(scope): …`, `test(scope): …` (e.g., `feat(core-types): add AI Chat types`).
- PRs include: purpose summary, linked issues (`Closes #123`), testing notes, and screenshots for UI.
- Checklist: formatted, analyzed, tests added/updated, docs touched where relevant.

## Security & Configuration
- Never commit secrets; use `.env` (see `.env.example`).
- Review changes in `scripts/` and `services/` for security impact.
- Remove unused dependencies and validate licenses before release.

## Temporary Limitations
- Share/Export/Publish UI is disabled by default to prioritize desktop client work.
- Feature flag: `ENABLE_SHARE_UI` — enable with `--dart-define=ENABLE_SHARE_UI=true` when building/testing Flutter modules.
- Tracking: TODO(P0) to restore full `ShareMenuButton` and menu behavior (see issue #7 or create one if missing).
