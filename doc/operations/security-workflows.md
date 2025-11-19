# Security Workflows

## Workflow: `security-audits.yml`
- **Triggers**
  - Pushes to `main`.
  - Pull requests targeting `main`.
  - Weekly scheduled run every Monday at 06:00 UTC.
  - Manual `workflow_dispatch` runs.
- **Matrix coverage**
  - Node.js versions: 18.x and 20.x.
  - Dart SDK channel: `stable`.

## Commands Executed
1. `npm ci`
2. `npm audit --audit-level=low`
3. `npx snyk test` (runs automatically when `SNYK_TOKEN` is configured; otherwise skipped with a note).
4. `dart pub get --directory pkg/core-logic`
5. `dart analyze pkg`
6. `npm run lint --prefix app` (skips when no lint script is defined in `app/package.json`).
7. `npm run lint --prefix scripts` (skips when no Node project is defined in `scripts/`).

Each command streams output into a markdown summary that is published as a workflow artifact and job summary for later review.

## Escalation Path
1. **Failed step or critical findings**
   - The workflow fails if `npm audit`, `npx snyk test`, or `dart analyze` return non-zero exit codes. Treat any failure as a release blocker.
2. **Initial response**
   - Assign an engineer from the owning team of the failing module (`app/`, `pkg/`, or `scripts/`).
   - Create a Security incident ticket in the internal tracker with logs from the uploaded `security-summary-*.md` artifact.
3. **Security team notification**
   - Notify the `#security-alerts` Slack channel (or the equivalent escalation channel) with a link to the failing run, the artifact, and the planned remediation timeline.
4. **Resolution and follow-up**
   - Implement patches, re-run the workflow via `workflow_dispatch`, and document the fix in the incident ticket.
   - For high-severity issues, follow disclosure guidelines from `SECURITY.md` and coordinate with the product owner before publishing changes.
