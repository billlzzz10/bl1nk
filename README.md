🧠 bl1nkOS Core Framework

bl1nkOS คือ Core Monorepo สำหรับแพลตฟอร์มจัดการ AI Agent (Agentic Framework) ที่เน้นความชัดเจน, ความปลอดภัย, และการบังคับใช้กฎแบบ deterministic

---

1. นี่คืออะไร (What it is)

สถาปัตยกรรมแบบ Full-Stack Monorepo ที่ใช้ L3 Hierarchy แบ่งเป็น:

🧩 app/ – Applications ที่ให้บริการ

- client-vscode: VS Code Extension (React) แบบ Thin Client  
- client-web: Web Dashboard สำหรับผู้ใช้ทั่วไป  
- client-cli: CLI สำหรับนักพัฒนา  
- server-trpc: Backend หลัก (tRPC/Express) สำหรับ User/Project CRUD  
- server-proxy: Gateway (FastAPI/Python) สำหรับ AI Logic และ Caching

🧠 pkg/ – Core Logic ที่ใช้ร่วมกัน

- core-logic: Business Logic กลาง เช่น Proxy Strategy  
- core-types: Shared Types/Schemas สำหรับ Client/Server  
- ui-components: Reusable UI Components  
- db-schema: Database Schema (Drizzle ORM)

🔌 services/ – External Dependencies

- redis: Exact Match Cache  
- qdrant: Semantic Search Cache

📑 doc/ – ระบบเอกสารอัตโนมัติ

- doc/pkg: เอกสารจาก packages  
- doc/app: เอกสารจาก applications  
- doc/changelogs: Changelog ตาม Event

🔒 constitution/ – Source of Truth สำหรับ Agent Rules

- bl1nk.manifest.json: ระบุ purpose, ruleset, dependencies สำหรับทุกโฟลเดอร์

---

2. ทำอะไร (What it does)

แพลตฟอร์มนี้ทำหน้าที่เป็น AI Memory Proxy ระดับองค์กร โดยมี logic หลัก:

- Cost Reduction (RLOGIC001):  
  ลดต้นทุน AI API 70–85% ด้วย Multi-Layer Caching:
  - Redis → Exact Match  
  - Qdrant → Semantic Search

- Resilience (RLOGIC002):  
  ใช้ Cascade Fallback Strategy สลับ Provider อัตโนมัติ (OpenAI, Google, Mistral)

- Enforcement (RMANIFEST001):  
  ทุกโฟลเดอร์ต้องมี bl1nk.manifest.json เพื่อบังคับใช้ Assembly Rules

- Type-Safety (RDEV003):  
  ใช้ tRPC และ JSON-RPC เพื่อให้ Client/Backend สื่อสารได้อย่างปลอดภัย

---

3. เริ่มอย่างไร (Getting Started)

`bash

1. ติดตั้ง dependencies
pnpm install

2. ตั้งค่า environment
cp .env.example .env

แก้ไข .env → DATABASE_URL, API Keys

3. สร้างฐานข้อมูล
pnpm db:create
pnpm db:migrate

4. รันเซิร์ฟเวอร์
pnpm dev
`

---

4. ระบบจัดการเอกสารอัตโนมัติ (Automated Documentation System)

📁 File Naming (RDOC002)

- เอกสาร: ตัวพิมพ์ใหญ่ + ขีดล่าง → README.md, CONTRIBUTING.md
- โค้ด: ใช้ kebab-case → server-proxy.ts, core-logic.ts

📜 Changelog Structure (RDOC003)

- อยู่ใน doc/changelogs/  
- แบ่งตาม Event เช่น FEATUREPROXYV2/  
- 01_INIT.md

🔒 Manifest Enforcement (RMANIFEST001)

- ทุกโฟลเดอร์ต้องมี bl1nk.manifest.json  
- ระบุ purpose, ruleset, dependencies  
- ใช้ตรวจสอบก่อน deploy หรือ generate artifact

---
