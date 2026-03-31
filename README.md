# 🧠 bl1nkOS Core Framework

`bl1nkOS` คือ Core Monorepo สำหรับแพลตฟอร์มจัดการ AI Agent (Agentic Framework) ที่เน้นความชัดเจน, ความปลอดภัย, และการบังคับใช้กฎแบบ deterministic

---

## 1. นี่คืออะไร (What it is)

สถาปัตยกรรมแบบ Full-Stack Monorepo ที่ใช้ **L3 Hierarchy** แบ่งเป็น:

### 🧩 `app/` – Applications ที่ให้บริการ

- `client-vscode`: VS Code Extension (React) แบบ Thin Client  
- `client-web`: Web Dashboard สำหรับผู้ใช้ทั่วไป  
- `client-cli`: CLI สำหรับนักพัฒนา  
- `server-trpc`: Backend หลัก (tRPC/Express) สำหรับ User/Project CRUD  
- `server-proxy`: Gateway (FastAPI/Python) สำหรับ AI Logic และ Caching

### 🧠 `pkg/` – Core Logic ที่ใช้ร่วมกัน

- `core-logic`: Business Logic กลาง เช่น Proxy Strategy  
- `core-types`: Shared Types/Schemas สำหรับ Client/Server  
- `ui-components`: Reusable UI Components  
- `db-schema`: Database Schema (Drizzle ORM)

### 🔌 `services/` – External Dependencies

- `redis`: Exact Match Cache  
- `qdrant`: Semantic Search Cache

### 📑 `doc/` – ระบบเอกสารอัตโนมัติ

- `doc/pkg`: เอกสารจาก packages  
- `doc/app`: เอกสารจาก applications  
- `doc/changelogs`: Changelog ตาม Event

### 🔒 `constitution/` – Source of Truth สำหรับ Agent Rules

- `bl1nk.manifest.json`: ระบุ `purpose`, `ruleset`, `dependencies` สำหรับทุกโฟลเดอร์

---

## 2. ทำอะไร (What it does)

แพลตฟอร์มนี้ทำหน้าที่เป็น **AI Memory Proxy** ระดับองค์กร โดยมี logic หลัก:

- **Cost Reduction (R_LOGIC_001):**  
  ลดต้นทุน AI API 70–85% ด้วย Multi-Layer Caching:
  - Redis → Exact Match  
  - Qdrant → Semantic Search

- **Resilience (R_LOGIC_002):**  
  ใช้ Cascade Fallback Strategy สลับ Provider อัตโนมัติ (OpenAI, Google, Mistral)

- **Enforcement (R_MANIFEST_001):**  
  ทุกโฟลเดอร์ต้องมี `bl1nk.manifest.json` เพื่อบังคับใช้ Assembly Rules

- **Type-Safety (R_DEV_003):**  
  ใช้ tRPC และ JSON-RPC เพื่อให้ Client/Backend สื่อสารได้อย่างปลอดภัย

---

## 3. เริ่มอย่างไร (Getting Started)

```bash
# 1. ติดตั้ง dependencies
pnpm install

# 2. ตั้งค่า environment
cp .env.example .env
# แก้ไข .env → DATABASE_URL, API Keys

# 3. สร้างฐานข้อมูล
pnpm db:create
pnpm db:migrate

# 4. รันเซิร์ฟเวอร์
pnpm dev
```

---

## 4. ระบบจัดการเอกสารอัตโนมัติ (Automated Documentation System)

### 📁 File Naming & Workflow (R_DOC_002)

- **เอกสาร**: ตัวพิมพ์ใหญ่ทั้งหมด + ขีดล่าง และใส่เลขสองหลักนำหน้าเพื่อเรียงความสำคัญ → `01_PROJECT_STATUS_AND_PLAN.md`, `07_WORK_TRACKING_MATRIX.md`
- **โค้ด**: ใช้ kebab-case → `server-proxy.ts`, `core-logic.ts`
- **Workflow**: ควบคุมผ่าน `.github/workflows/auto-project.yml` เพื่อตรวจสอบชื่อไฟล์และอัปเดต metadata อัตโนมัติ

ดูรายละเอียดเพิ่มเติมที่ [07_WORK_TRACKING_MATRIX.md](doc/07_WORK_TRACKING_MATRIX.md)

### 📜 Changelog Structure (R_DOC_003)

- อยู่ใน `doc/changelogs/`  
- แบ่งตาม Event เช่น `FEATURE_PROXY_V2/`  
- ไฟล์ย่อยขึ้นต้นด้วยตัวเลข + ALL CAPS → `01_INIT.MD`

### 🔒 Manifest Enforcement (R_MANIFEST_001)

- ทุกโฟลเดอร์ต้องมี `bl1nk.manifest.json`  
- ระบุ `purpose`, `ruleset`, `dependencies`  
 - ใช้ตรวจสอบก่อน deploy หรือ generate artifact

---

## 5. Feature Flags (Flutter/Dart)

ชั่วคราว: UI สำหรับ Share/Export/Publish ถูกปิดค่าเริ่มต้นเพื่อโฟกัสไคลเอนต์เดสก์ทอป หากต้องทดสอบเมนูชั่วคราว ให้เปิดแฟลก `ENABLE_SHARE_UI` ตามตัวอย่างนี้:

```bash
# Flutter (run บน macOS)
flutter run -d macos --dart-define=ENABLE_SHARE_UI=true

# Flutter (run บน Windows)
flutter run -d windows --dart-define=ENABLE_SHARE_UI=true

# Flutter build release (ตัวอย่าง macOS)
flutter build macos --release --dart-define=ENABLE_SHARE_UI=true

# Flutter tests พร้อมแฟลก
flutter test --dart-define=ENABLE_SHARE_UI=true

# Pure Dart (เช่น รันตัวอย่าง/สคริปต์)
dart run -D ENABLE_SHARE_UI=true path/to/app.dart
```

หมายเหตุ: เมื่อไม่ใส่แฟลก ปุ่ม Share จะปรากฏเป็นสถานะปิดการใช้งานพร้อม tooltip "Coming soon" เพื่อคง layout และลดความสับสนผู้ใช้

---

## 6. Desktop (Windows) — Electron + TypeScript

ที่อยู่โค้ด: `app/client-desktop`

คำสั่งพัฒนาและรัน (ต้องติดตั้ง Node.js และ npm):

```bash
cd app/client-desktop

# ติดตั้ง dependencies
npm install

# พัฒนา (watch + auto-reload)
# เปิดเมนู Share/Chat ชั่วคราวด้วยแฟลก (ทางเลือก)
cross-env ENABLE_SHARE_UI=true ENABLE_CHAT_UI=true npm run dev

# สร้างไฟล์ build TypeScript
npm run build

# รันแอปจาก build
npm start
```

หมายเหตุ:
- ค่าเริ่มต้นปุ่ม Share เป็น disabled + tooltip "Coming soon"
- ตั้งค่าแฟลก `ENABLE_SHARE_UI=true` เพื่อเปิดเมนู Share/Export/Publish (placeholder)

---

## 7. ความปลอดภัย (Security)

- [Operations Runbooks](doc/operations/index.md): รวมขั้นตอน Incident Response และงานบำรุงรักษา
- [Metadata Maintenance Guide](doc/operations/metadata-maintenance.md): วิธีอัปเดต checksum/timestamp สำหรับไฟล์ระบบสำคัญ
