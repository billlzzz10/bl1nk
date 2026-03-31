# 07 WORK TRACKING MATRIX

## 📋 Overview
This document formalizes the documentation and project tracking automation flow, capturing the naming, numbering, and status updates for the bl1nkOS project.

---

## 📁 Naming & Numbering Rules (R_DOC_002)

To ensure a deterministic and orderly documentation system, all files within the `doc/` directory must adhere to the following naming conventions:

### 📑 Documentation Files
- **Format**: `XX_ALL_CAPS_UNDERSCORE.md`
- **Rule**: Must start with a two-digit prefix (e.g., `01_`, `02_`) followed by descriptive names in all capital letters with underscores.
- **Example**: `01_MASTER_PLAN.md`, `07_WORK_TRACKING_MATRIX.md`.

### 📜 Changelogs (R_DOC_003)
- **Format**: `doc/changelogs/EVENT_NAME/XX_ALL_CAPS.md`
- **Rule**: Grouped by major events or features. Individual entries are numbered.
- **Example**: `doc/changelogs/FEATURE_PROXY_V2/01_INIT.MD`.

### 💻 Source Code
- **Format**: `kebab-case`
- **Rule**: Lowercase letters with hyphens.
- **Example**: `server-proxy.ts`, `core-logic.ts`.

---

## 🤖 Automated Documentation Workflow

The project utilizes GitHub Actions to enforce these rules and maintain system integrity.

### ⚙️ Workflow: `auto-project.yml`
- **Trigger**: Pushes to `main`, Pull Requests, or manual execution.
- **Key Functions**:
  1. **Metadata Validation**: Ensures `bl1nk.manifest.json` and system files have up-to-date checksums and timestamps.
  2. **Naming Enforcement**: Validates that all new `.md` files in the `doc/` root follow the `XX_ALL_CAPS` rule.
  3. **Automated Updates**: Runs `scripts/update-system-metadata.ts` to sync the `system-map.json` and operation runbooks.

### 🛠️ Maintenance Commands
- **Update Metadata**: `npm run update:system-metadata`
- **Dry Run**: `npm run update:system-metadata -- --dry-run`

---

## 📊 Work Tracking Matrix

| ID | Task | Status | Ruleset | Description |
|:---|:---|:---:|:---|:---|
| **P1** | Core Architecture | ✅ | R_ASSEMBLY_001 | L3 Hierarchy, Monorepo Scaffolding |
| **P2** | Manifest System | ✅ | R_MANIFEST_001 | Folder-level compliance and rulesets |
| **P3** | Documentation Flow | ✅ | R_DOC_001 | Automated naming and metadata system |
| **P4** | Secure Auth | 🏗️ | R_SEC_002 | tRPC + JWT integration |
| **P5** | Chat & RAG | 🏗️ | R_LOGIC_001 | Multi-layer caching and semantic search |

---
**Last Updated**: 2025-01-24
