# Chat & RAG Implementation Blueprint

## 🎯 Overview

พิมพ์เขียวการใช้งานจริง (Implementation Blueprint) ที่สมบูรณ์สำหรับส่วน "Chat" และ "RAG" (Retrieval-Augmented Generation) ซึ่ง "แมพ" เข้ากับสถาปัตยกรรม 40/60 ที่ตกลงกันไว้

**Key Principles:**
- **40% Client (Flutter/Desktop)**: Smart Controller ที่เบาและตอบสนองเร็ว
- **60% Server**: สมองและตัวแบกงาน (Workhorse) ทั้งหมด งานที่ "กินทรัพยากร" อยู่ที่นี่
- **Schema**: ใช้ `Threads` / `Messages` / `Context` แทน Agent ที่ซับซ้อน (สะอาดและตรงประเด็น)

---

## 📋 Table of Contents

1. [Master Data Blueprint](#1-master-data-blueprint)
2. [40/60 Architecture Split](#2-4060-architecture-split)
3. [Priority Implementation Roadmap](#3-priority-implementation-roadmap)
4. [API Specifications](#4-api-specifications)
5. [Vector DB Integration](#5-vector-db-integration)
6. [RAG Implementation Workflow](#6-rag-implementation-workflow)
7. [Client Implementation Guide](#7-client-implementation-guide)
8. [Testing & Validation](#8-testing--validation)

---

## 1. Master Data Blueprint

### A. Business Logic (Auth, Billing, Workspaces)

```sql
-- Accounts (Auth, 2FA/Passkeys)
CREATE TABLE accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- Workspaces (Container หลัก)
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Workspace Members (จัดการสิทธิ์, RLS/ACL)
CREATE TABLE workspace_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner','admin','member','viewer')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (workspace_id, account_id)
);

-- Subscriptions (Billing, Status) - TODO: Add when needed
-- CREATE TABLE subscriptions (...);
```

### B. Chat/File Logic (Product Data - ต้องซิงค์)

```sql
-- Chat Threads
CREATE TABLE chat_threads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  title TEXT,
  model_config JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX chat_threads_ws_updated_idx ON chat_threads (workspace_id, updated_at DESC);

-- Chat Messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id UUID NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user','assistant')),
  text TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','streaming','completed','error')),
  meta JSONB, -- เก็บ ChatMessageMeta/ChatViewReference
  parent_id UUID REFERENCES chat_messages(id) ON DELETE SET NULL, -- สำหรับ Branch
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX chat_messages_thread_created_idx ON chat_messages (thread_id, created_at ASC);
CREATE INDEX chat_messages_ws_created_idx ON chat_messages (workspace_id, created_at DESC);

-- Context Files
CREATE TABLE chat_context_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  source_type TEXT NOT NULL CHECK (source_type IN ('upload','web')),
  loader_type TEXT NOT NULL CHECK (loader_type IN ('pdf','txt','markdown','unknown')),
  path TEXT,
  url TEXT,
  hash TEXT, -- SHA256
  status TEXT NOT NULL CHECK (status IN ('uploading','pending_chunks','ready','error')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (workspace_id, hash)
);

-- Thread Attachments (ตารางเชื่อม)
CREATE TABLE thread_attachments (
  thread_id UUID NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,
  file_id UUID NOT NULL REFERENCES chat_context_files(id) ON DELETE CASCADE,
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (thread_id, file_id)
);
```

**RLS Policies (บังคับใช้ทุก Request):**

```sql
-- Enable RLS
ALTER TABLE chat_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_context_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE thread_attachments ENABLE ROW LEVEL SECURITY;

-- Example Policy (ตรวจสอบสิทธิ์ผ่าน workspace_members)
CREATE POLICY chat_threads_workspace_members ON chat_threads
  FOR ALL
  USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members
      WHERE account_id = current_setting('app.account_id')::UUID
    )
  );
```

### C. Vector DB Collections (Qdrant)

#### Collection 1: `messages_embeddings`
**Purpose:** เก็บ Vector ของ Messages สำหรับ RAG

**Payload Schema:**
```json
{
  "workspace_id": "uuid",
  "thread_id": "uuid",
  "message_id": "uuid",
  "role": "user|assistant",
  "text": "string (excerpt, first 500 chars)",
  "created_at": "timestamp"
}
```

**Vector:** 768d (Google Embeddings) หรือ 1024d (Voyage AI)

**Indexes:**
- `workspace_id` (exact match, filter)
- `thread_id` (exact match, filter)
- `created_at` (range, for temporal queries)

#### Collection 2: `file_chunks_embeddings`
**Purpose:** เก็บ Vector ของ File Chunks สำหรับ RAG

**Payload Schema:**
```json
{
  "workspace_id": "uuid",
  "context_file_id": "uuid",
  "chunk_id": "uuid",
  "loader_type": "pdf|txt|markdown",
  "sha256": "string",
  "chunk_text": "string (excerpt, first 500 chars)",
  "chunk_index": "integer",
  "total_chunks": "integer",
  "token_count": "integer",
  "created_at": "timestamp"
}
```

**Vector:** 768d (Google Embeddings) หรือ 1024d (Voyage AI)

**Indexes:**
- `workspace_id` (exact match, filter)
- `context_file_id` (exact match, filter)
- `loader_type` (exact match, filter)

### D. Orchestration (Async Jobs)

```sql
-- Async Jobs (งานชั่วคราว)
CREATE TABLE jobs (
  job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL CHECK (job_type IN (
    'export',
    'publish',
    'file_chunking',
    'file_embedding',
    'reindex_embeddings',
    'cleanup',
    'backfill'
  )),
  payload JSONB NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','running','completed','failed','canceled')) DEFAULT 'pending',
  attempts INT NOT NULL DEFAULT 0,
  max_attempts INT NOT NULL DEFAULT 3,
  priority INT NOT NULL DEFAULT 0,
  dedup_key TEXT, -- สำหรับป้องกัน duplicate jobs
  scheduled_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX jobs_dedup_key_uidx ON jobs (dedup_key) WHERE dedup_key IS NOT NULL;
CREATE INDEX jobs_ws_status_idx ON jobs (workspace_id, status, priority, COALESCE(scheduled_at, created_at));

-- Share States
CREATE TABLE share_states (
  entity_id UUID PRIMARY KEY REFERENCES chat_threads(id) ON DELETE CASCADE,
  visibility TEXT NOT NULL CHECK (visibility IN ('private','workspace','public','url')),
  slug TEXT UNIQUE,
  url TEXT,
  permissions JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Publish States
CREATE TABLE publish_states (
  entity_id UUID PRIMARY KEY REFERENCES chat_threads(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('draft','published','unpublished')),
  slug TEXT UNIQUE,
  last_published_at TIMESTAMPTZ
);
```

---

## 2. 40/60 Architecture Split

### 🖥️ 40% Client (Flutter/Desktop) - "Smart Controller"

**หน้าที่:** เป็น UI Controller ที่เบาและตอบสนองเร็ว

**สิ่งที่ Client ต้องทำ:**

1. **UI & State Management**
   - จัดการการแสดงผล `Threads`, `Messages` ทั้งหมด
   - ใช้ Flutter Bloc/Cubit สำหรับ state management
   - Local state caching (SQLite/Isar) สำหรับ offline-first experience

2. **Local Caching**
   - เก็บ `ChatThreads` และ `ChatMessages` ที่ใช้บ่อยไว้ใน DB ท้องถิ่น
   - Sync strategy: Background sync + optimistic updates
   - Cache invalidation: เมื่อได้รับ SSE events จาก server

3. **Authentication**
   - จัดการ `Session_Token` (เก็บอย่างปลอดภัยใน secure storage)
   - Handle token refresh
   - Call API ด้วย headers ที่ถูกต้อง

4. **File Upload (เริ่มต้นเท่านั้น)**
   - จัดการการเลือกไฟล์จาก user
   - เรียก `POST /files` เพื่อขอ Signed URL
   - Upload ไฟล์ไปที่ S3/Storage โดยตรง (ไม่ผ่าน server)
   - เรียก `POST /files/:id/complete` เมื่อ upload เสร็จ

5. **Rendering**
   - แสดงผล Markdown, Code Blocks
   - Syntax highlighting
   - Image previews

6. **API Calls**
   - เรียก API (tRPC/HTTP) ทั้งหมดที่ server expose
   - Handle SSE streams (`/messages/stream/:id`)
   - Error handling และ retry logic

**สิ่งที่ Client ไม่ต้องทำ:**
- ❌ File processing (chunking, embedding)
- ❌ Vector search
- ❌ AI API calls (ใช้ Master Keys ของบริษัท)
- ❌ Token counting (server ทำ)
- ❌ Job orchestration

### ☁️ 60% Server - "The Real Product"

**หน้าที่:** สมองและตัวแบกงาน (Workhorse) ทั้งหมด

**สิ่งที่ Server ต้องทำ:**

1. **Database (SQL + Vector)**
   - เก็บข้อมูลทั้งหมด (ตาม Schema ข้างบน)
   - Postgres: Source of truth (metadata, relations, audit)
   - Qdrant: Vector embeddings (semantic search only)

2. **Auth & RLS**
   - ตรวจสอบสิทธิ์ "ทุก" Request
   - ใช้ `current_setting('app.account_id')` สำหรับ RLS
   - Validate JWT tokens
   - Check workspace membership

3. **File Processing (งานหนัก)**
   - เมื่อไฟล์อัปโหลดเสร็จ (`POST /files/:id/complete`):
     - สร้าง `Async_Job` สำหรับ `file_chunking`
     - Worker process: Chunking (แบ่งไฟล์เป็นชิ้น)
     - Worker process: Embedding (สร้าง Vector)
     - Worker process: Storing (เก็บใน `file_chunks_embeddings`)
     - Update `chat_context_files.status = 'ready'`
   - **นี่คือส่วนสำคัญที่ "ไม่กินทรัพยากรเครื่อง" ผู้ใช้เลย**

4. **AI Orchestrator (หัวใจ)**
   - เมื่อ Client ส่ง `POST /messages`:
     - **RAG Retrieval:**
       - ค้นหา Vector จาก `messages_embeddings` (messages ใน thread เดียวกัน)
       - ค้นหา Vector จาก `file_chunks_embeddings` (files ที่ attach กับ thread)
       - รวม context ที่ได้มาเป็น prompt
     - **Token Swapping:**
       - เลือกโมเดลที่ถูกที่สุด/เหมาะที่สุด (ตาม `model_config`)
       - ใช้ Master Keys ของบริษัท (ไม่ใช่ keys ของผู้ใช้)
     - **Smart Caching:**
       - ตรวจสอบ Redis cache (exact match)
       - ตรวจสอบ Qdrant cache (semantic match)
       - ลดการยิง API ลง 70-85%
     - **API Call:**
       - ยิง API ไปยัง AI ภายนอก (OpenAI, Anthropic, Google, Mistral)
       - Stream (SSE) ผลลัพธ์กลับไปหา Client
       - Update `chat_messages.status` (pending → streaming → completed)
     - **Post-processing:**
       - สร้าง embedding ของ assistant message
       - เก็บใน `messages_embeddings` (สำหรับ RAG ครั้งต่อไป)

5. **Jobs (Export/Publish)**
   - จัดการงานที่ใช้เวลานาน (เช่น สร้าง PDF) ในเบื้องหลัง
   - SSE endpoint สำหรับ job status (`/jobs/:id/status`)
   - Retry logic และ error handling

6. **Rate Limiting & Quotas**
   - ตรวจสอบ subscription limits
   - Rate limiting per workspace
   - Token usage tracking

---

## 3. Priority Implementation Roadmap

### Priority 1: Auth & Core Structure ✅

**Goal:** การยืนยันตัวตนและโครงสร้างพื้นฐาน

**Server Tasks:**

1. **Database Setup**
   - ✅ Schema อยู่แล้ว (ดู `migrations/001_init.sql`)
   - เพิ่ม migration สำหรับ RLS policies

2. **Auth Implementation**
   ```typescript
   // app/server-trpc/src/routes/auth.ts
   POST /auth/register
   POST /auth/login
   POST /auth/refresh
   GET /auth/me
   ```

3. **Workspace API**
   ```typescript
   // app/server-trpc/src/routes/workspaces.ts
   GET /workspaces (list user's workspaces)
   GET /workspaces/:id (get workspace details)
   POST /workspaces (create workspace)
   ```

4. **Middleware: Auth + RLS**
   ```typescript
   // app/server-trpc/src/middleware/auth.ts
   - Verify JWT token
   - Set app.account_id via current_setting()
   - Check workspace access
   ```

**Client Tasks:**

1. **Auth UI**
   - Login/Register screens
   - Session management
   - Token storage (secure)

2. **Workspace List**
   - Display user's workspaces
   - Switch workspace

**DoD (Definition of Done):**
- ✅ Login → ได้ JWT token
- ✅ `GET /workspaces` → แสดง list workspaces
- ✅ RLS ทำงาน (test: เรียก API ด้วย token ที่ไม่มีสิทธิ์ → 403)

---

### Priority 2: Chat Core 💬

**Goal:** หัวใจการแชท - สร้าง/อ่าน Threads และ Messages

**Server Tasks:**

1. **Database Integration**
   - Replace in-memory Map ด้วย Postgres queries
   - Implement pagination

2. **Threads API**
   ```typescript
   // app/server-trpc/src/routes/threads.ts
   POST /threads
     - Create new thread
     - Input: { workspaceId, title?, modelConfig? }
     - Output: ChatThread
   
   GET /threads
     - List threads for workspace
     - Query: { workspaceId, limit?, offset? }
     - Output: ChatThread[]
   
   GET /threads/:id
     - Get thread details
     - Output: ChatThread
   
   PATCH /threads/:id
     - Update thread (title, modelConfig)
   
   DELETE /threads/:id
     - Soft delete or hard delete
   ```

3. **Messages API**
   ```typescript
   // app/server-trpc/src/routes/messages.ts
   POST /messages
     - Create user message
     - Input: { threadId, workspaceId, text, parentId?, meta? }
     - Output: { messageId }
     - Create message with status='pending'
     - Trigger AI Orchestrator (async)
   
   GET /messages
     - List messages for thread
     - Query: { threadId, limit?, offset? }
     - Output: ChatMessage[]
   
   GET /messages/:id
     - Get message details
   ```

4. **SSE Streaming (State Machine)**
   ```typescript
   // app/server-trpc/src/routes/stream.ts
   GET /messages/stream/:messageId
     - SSE endpoint สำหรับ streaming response
     - Events:
       * status: pending → streaming → completed/error
       * delta: text chunks
       * done: true/false
     - Update chat_messages.status และ text ใน real-time
   ```

**Client Tasks:**

1. **Chat UI**
   - Thread list sidebar
   - Message list (scrollable)
   - Input field (send message)
   - Loading states

2. **SSE Integration**
   - Connect to `/messages/stream/:id`
   - Update UI ใน real-time (append delta)
   - Handle connection errors และ reconnect

3. **Local Cache**
   - SQLite/Isar database
   - Cache recent threads/messages
   - Sync strategy: Fetch on app start, background refresh

**DoD:**
- ✅ Create thread → แสดงใน UI
- ✅ Send message → ได้ response ผ่าน SSE
- ✅ Messages แสดงใน UI แบบ real-time
- ✅ Offline: แสดง cached messages

---

### Priority 3: AI Orchestrator 🤖

**Goal:** เชื่อมต่อ AI จริง - RAG, Streaming, Caching

**Server Tasks:**

1. **AI Service Layer**
   ```typescript
   // app/server-trpc/src/services/ai-orchestrator.ts
   class AIOrchestrator {
     async generateResponse(
       threadId: string,
       messageId: string,
       modelConfig: ModelConfig
     ): Promise<ReadableStream>
   }
   ```

2. **RAG Retrieval**
   ```typescript
   // app/server-trpc/src/services/rag-retrieval.ts
   async function retrieveContext(
     threadId: string,
     workspaceId: string,
     query: string
   ): Promise<RetrievedContext[]> {
     // 1. Search messages_embeddings (same thread)
     // 2. Search file_chunks_embeddings (attached files)
     // 3. Combine and rank results
     // 4. Return top-k chunks
   }
   ```

3. **Vector Search (Qdrant)**
   ```typescript
   // app/server-trpc/src/services/qdrant-service.ts
   async function searchMessages(
     workspaceId: string,
     threadId: string,
     queryVector: number[],
     limit: number
   ): Promise<MessageEmbedding[]>
   
   async function searchFileChunks(
     workspaceId: string,
     fileIds: string[],
     queryVector: number[],
     limit: number
   ): Promise<FileChunkEmbedding[]>
   ```

4. **Embedding Generation**
   ```typescript
   // app/server-trpc/src/services/embedding-service.ts
   async function generateEmbedding(text: string): Promise<number[]>
   // Use Google Embeddings API หรือ Voyage AI
   ```

5. **Token Swapping & Model Selection**
   ```typescript
   // app/server-trpc/src/services/model-selector.ts
   function selectModel(
     modelConfig: ModelConfig,
     contextLength: number,
     budget: 'low' | 'medium' | 'high'
   ): { provider: string, modelId: string }
   ```

6. **Smart Caching**
   ```typescript
   // app/server-trpc/src/services/cache-service.ts
   // Redis: Exact match cache
   // Qdrant: Semantic cache (similar queries)
   async function checkCache(query: string): Promise<CachedResponse | null>
   ```

7. **Streaming Response**
   ```typescript
   // app/server-trpc/src/services/ai-streaming.ts
   async function streamAIResponse(
     messages: ChatMessage[],
     context: RetrievedContext[],
     modelConfig: ModelConfig
   ): Promise<ReadableStream>
   // Update chat_messages.text และ status ใน real-time
   ```

8. **Post-processing**
   - Generate embedding สำหรับ assistant message
   - Store in `messages_embeddings` collection

**Client Tasks:**

1. **Model Selection UI**
   - Dropdown สำหรับเลือก provider/model
   - Save to `model_config`

2. **Streaming Display**
   - Real-time text updates
   - Typing indicators
   - Error states

**DoD:**
- ✅ Send message → AI response ผ่าน SSE
- ✅ RAG ทำงาน (ค้นหา context จาก messages และ files)
- ✅ Caching ลด API calls ลง 70%+
- ✅ Token swapping เลือกโมเดลที่เหมาะสม

---

### Priority 4: File Context & RAG 📁

**Goal:** การเพิ่มไฟล์และทำ RAG จากไฟล์

**Server Tasks:**

1. **File Upload API**
   ```typescript
   // app/server-trpc/src/routes/files.ts
   POST /files
     - Request signed URL for upload
     - Input: { name, size, mimeType, workspaceId }
     - Output: { fileId, uploadUrl, expiresAt }
   
   POST /files/:id/complete
     - Notify server that upload is complete
     - Create job for file_chunking
     - Update chat_context_files.status = 'pending_chunks'
   
   GET /files/:id
     - Get file metadata
   
   GET /files
     - List files for workspace
   ```

2. **Job System (File Processing)**
   ```typescript
   // app/server-trpc/src/jobs/file-processing.ts
   async function processFile(fileId: string) {
     // 1. Download file from S3/R2
     // 2. Detect loader_type (pdf, txt, markdown)
     // 3. Chunk file (split into chunks)
     // 4. Generate embeddings for each chunk
     // 5. Store in file_chunks_embeddings
     // 6. Update chat_context_files.status = 'ready'
   }
   ```

3. **Chunking Service**
   ```typescript
   // app/server-trpc/src/services/chunking-service.ts
   class ChunkingService {
     async chunkPDF(file: Buffer): Promise<Chunk[]>
     async chunkText(text: string): Promise<Chunk[]>
     async chunkMarkdown(markdown: string): Promise<Chunk[]>
   }
   ```

4. **File Attachments API**
   ```typescript
   // app/server-trpc/src/routes/attachments.ts
   POST /threads/:threadId/attachments
     - Attach file to thread
     - Input: { fileId }
     - Creates thread_attachments record
   
   DELETE /threads/:threadId/attachments/:fileId
     - Remove attachment
   ```

5. **Update RAG Retrieval**
   - รวม file chunks ใน context retrieval
   - Filter by attached files only

6. **Job Status API**
   ```typescript
   GET /jobs/:id
     - Get job status
   
   GET /jobs/:id/status (SSE)
     - Stream job status updates
   ```

**Client Tasks:**

1. **File Upload UI**
   - File picker
   - Upload progress
   - File list (attached files)

2. **Attachment UI**
   - Attach file button
   - Show attached files in thread
   - Remove attachment

3. **Job Status Display**
   - Show processing status (uploading → processing → ready)
   - Error messages

**DoD:**
- ✅ Upload file → ได้ signed URL → upload ไป S3
- ✅ File processing → chunking → embedding → ready
- ✅ Attach file → RAG ใช้ file chunks ใน context
- ✅ Job status updates แบบ real-time

---

### Priority 5: Features (Share/Export/Publish) 🚀

**Goal:** ฟีเจอร์เสริม

**Server Tasks:**

1. **Share API**
   ```typescript
   POST /threads/:id/share
     - Create share link
     - Input: { visibility: 'private' | 'workspace' | 'public' | 'url' }
     - Output: { slug, url }
   
   GET /shared/:slug
     - Get shared thread (public access)
   ```

2. **Export API**
   ```typescript
   POST /threads/:id/export
     - Create export job
     - Input: { format: 'pdf' | 'markdown' | 'txt' }
     - Output: { jobId }
   
   GET /export/:jobId
     - Get export file URL
   ```

3. **Publish API**
   ```typescript
   POST /threads/:id/publish
     - Publish thread (make public)
     - Input: { slug? }
     - Output: { slug, url }
   ```

4. **Model Presets API**
   ```typescript
   GET /model-presets
     - List available model presets
   
   POST /model-presets
     - Create custom preset
   ```

**Client Tasks:**

1. **Share UI**
   - Share button
   - Share settings modal
   - Copy link

2. **Export UI**
   - Export button
   - Format selection
   - Download progress

3. **Model Presets UI**
   - Preset selector
   - Custom preset editor

**DoD:**
- ✅ Share → ได้ link ที่ใช้งานได้
- ✅ Export → ได้ไฟล์ PDF/Markdown
- ✅ Publish → thread กลายเป็น public

---

## 4. API Specifications

### Authentication

**Base URL:** `https://api.bl1nk.app` (production) หรือ `http://localhost:3333` (dev)

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

### Endpoints Summary

| Method | Endpoint | Description | Priority |
|--------|----------|-------------|----------|
| `POST` | `/auth/register` | Register new account | 1 |
| `POST` | `/auth/login` | Login | 1 |
| `POST` | `/auth/refresh` | Refresh token | 1 |
| `GET` | `/auth/me` | Get current user | 1 |
| `GET` | `/workspaces` | List workspaces | 1 |
| `GET` | `/workspaces/:id` | Get workspace | 1 |
| `POST` | `/workspaces` | Create workspace | 1 |
| `POST` | `/threads` | Create thread | 2 |
| `GET` | `/threads` | List threads | 2 |
| `GET` | `/threads/:id` | Get thread | 2 |
| `PATCH` | `/threads/:id` | Update thread | 2 |
| `DELETE` | `/threads/:id` | Delete thread | 2 |
| `POST` | `/messages` | Create message | 2 |
| `GET` | `/messages` | List messages | 2 |
| `GET` | `/messages/stream/:id` | Stream message (SSE) | 2 |
| `POST` | `/files` | Request upload URL | 4 |
| `POST` | `/files/:id/complete` | Complete upload | 4 |
| `GET` | `/files` | List files | 4 |
| `POST` | `/threads/:id/attachments` | Attach file | 4 |
| `GET` | `/jobs/:id` | Get job status | 4 |
| `GET` | `/jobs/:id/status` | Stream job status (SSE) | 4 |

### Request/Response Examples

#### Create Thread
```typescript
POST /threads
{
  "workspaceId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My Chat Thread",
  "modelConfig": {
    "provider": "openai",
    "modelId": "gpt-4o-mini",
    "params": {
      "temperature": 0.7,
      "maxTokens": 2000
    }
  }
}

Response 201:
{
  "id": "660e8400-e29b-41d4-a716-446655440000",
  "workspaceId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My Chat Thread",
  "modelConfig": {
    "provider": "openai",
    "modelId": "gpt-4o-mini",
    "params": { "temperature": 0.7, "maxTokens": 2000 }
  },
  "createdAt": 1704067200000,
  "updatedAt": 1704067200000
}
```

#### Create Message
```typescript
POST /messages
{
  "threadId": "660e8400-e29b-41d4-a716-446655440000",
  "workspaceId": "550e8400-e29b-41d4-a716-446655440000",
  "text": "What is the meaning of life?",
  "parentId": null,
  "meta": {}
}

Response 201:
{
  "messageId": "770e8400-e29b-41d4-a716-446655440000"
}

// Then connect to SSE:
GET /messages/stream/770e8400-e29b-41d4-a716-446655440000

SSE Events:
data: {"type":"status","status":"pending"}
data: {"type":"status","status":"streaming"}
data: {"type":"delta","text":"The meaning of life"}
data: {"type":"delta","text":" is a philosophical"}
data: {"type":"delta","text":" question..."}
data: {"type":"done","done":true}
data: {"type":"status","status":"completed"}
```

#### File Upload Flow
```typescript
// Step 1: Request upload URL
POST /files
{
  "name": "document.pdf",
  "size": 1024000,
  "mimeType": "application/pdf",
  "workspaceId": "550e8400-e29b-41d4-a716-446655440000"
}

Response 201:
{
  "fileId": "880e8400-e29b-41d4-a716-446655440000",
  "uploadUrl": "https://s3.bl1nk.app/upload/...",
  "expiresAt": 1704067300000
}

// Step 2: Upload file to S3 (client-side)
PUT <uploadUrl>
Content-Type: application/pdf
<body: file bytes>

// Step 3: Notify server
POST /files/880e8400-e29b-41d4-a716-446655440000/complete

Response 202:
{
  "jobId": "990e8400-e29b-41d4-a716-446655440000",
  "status": "pending"
}
```

---

## 5. Vector DB Integration

### Qdrant Setup

**Collection: `messages_embeddings`**

```typescript
// app/server-trpc/src/services/qdrant-service.ts
import { QdrantClient } from '@qdrant/js-client-rest';

const qdrant = new QdrantClient({
  url: process.env.QDRANT_URL || 'http://localhost:6333',
  apiKey: process.env.QDRANT_API_KEY,
});

// Create collection
await qdrant.createCollection('messages_embeddings', {
  vectors: {
    size: 768, // Google Embeddings dimension
    distance: 'Cosine',
  },
});

// Create payload index
await qdrant.createPayloadIndex('messages_embeddings', {
  field_name: 'workspace_id',
  field_schema: 'keyword',
});

await qdrant.createPayloadIndex('messages_embeddings', {
  field_name: 'thread_id',
  field_schema: 'keyword',
});
```

**Collection: `file_chunks_embeddings`**

```typescript
await qdrant.createCollection('file_chunks_embeddings', {
  vectors: {
    size: 768,
    distance: 'Cosine',
  },
});

await qdrant.createPayloadIndex('file_chunks_embeddings', {
  field_name: 'workspace_id',
  field_schema: 'keyword',
});

await qdrant.createPayloadIndex('file_chunks_embeddings', {
  field_name: 'context_file_id',
  field_schema: 'keyword',
});
```

### Embedding Service

```typescript
// app/server-trpc/src/services/embedding-service.ts
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY!);

export async function generateEmbedding(text: string): Promise<number[]> {
  const model = genAI.getGenerativeModel({ model: 'embedding-001' });
  const result = await model.embedContent(text);
  return result.embedding.values;
}
```

### Vector Search

```typescript
// Search messages
async function searchMessages(
  workspaceId: string,
  threadId: string,
  query: string,
  limit: number = 5
): Promise<MessageEmbedding[]> {
  const queryVector = await generateEmbedding(query);
  
  const results = await qdrant.search('messages_embeddings', {
    vector: queryVector,
    limit,
    filter: {
      must: [
        { key: 'workspace_id', match: { value: workspaceId } },
        { key: 'thread_id', match: { value: threadId } },
      ],
    },
  });
  
  return results.map((r) => ({
    messageId: r.payload!.message_id as string,
    text: r.payload!.text as string,
    score: r.score,
  }));
}

// Search file chunks
async function searchFileChunks(
  workspaceId: string,
  fileIds: string[],
  query: string,
  limit: number = 5
): Promise<FileChunkEmbedding[]> {
  const queryVector = await generateEmbedding(query);
  
  const results = await qdrant.search('file_chunks_embeddings', {
    vector: queryVector,
    limit,
    filter: {
      must: [
        { key: 'workspace_id', match: { value: workspaceId } },
        { key: 'context_file_id', match: { any: fileIds } },
      ],
    },
  });
  
  return results.map((r) => ({
    chunkId: r.payload!.chunk_id as string,
    fileId: r.payload!.context_file_id as string,
    text: r.payload!.chunk_text as string,
    score: r.score,
  }));
}
```

### Storing Embeddings

```typescript
// Store message embedding
async function storeMessageEmbedding(
  messageId: string,
  threadId: string,
  workspaceId: string,
  text: string,
  role: 'user' | 'assistant'
): Promise<void> {
  const vector = await generateEmbedding(text);
  
  await qdrant.upsert('messages_embeddings', {
    wait: true,
    points: [
      {
        id: messageId,
        vector,
        payload: {
          workspace_id: workspaceId,
          thread_id: threadId,
          message_id: messageId,
          role,
          text: text.substring(0, 500), // Excerpt
          created_at: new Date().toISOString(),
        },
      },
    ],
  });
}

// Store file chunk embeddings
async function storeFileChunkEmbeddings(
  fileId: string,
  workspaceId: string,
  chunks: Chunk[]
): Promise<void> {
  const points = await Promise.all(
    chunks.map(async (chunk) => {
      const vector = await generateEmbedding(chunk.text);
      return {
        id: chunk.id,
        vector,
        payload: {
          workspace_id: workspaceId,
          context_file_id: fileId,
          chunk_id: chunk.id,
          loader_type: chunk.loaderType,
          sha256: chunk.sha256,
          chunk_text: chunk.text.substring(0, 500),
          chunk_index: chunk.index,
          total_chunks: chunks.length,
          token_count: chunk.tokenCount,
          created_at: new Date().toISOString(),
        },
      };
    })
  );
  
  await qdrant.upsert('file_chunks_embeddings', {
    wait: true,
    points,
  });
}
```

---

## 6. RAG Implementation Workflow

### Flow Diagram

```
User sends message
    ↓
1. Create message (status='pending')
    ↓
2. RAG Retrieval:
   - Generate query embedding
   - Search messages_embeddings (same thread)
   - Search file_chunks_embeddings (attached files)
   - Combine and rank results
    ↓
3. Build context prompt
    ↓
4. Check cache (Redis + Qdrant semantic cache)
    ↓
5. If cache hit → return cached response
   If cache miss → proceed to AI call
    ↓
6. Select model (token swapping)
    ↓
7. Call AI API (streaming)
    ↓
8. Stream response to client (SSE)
    ↓
9. Update message (status='completed', text=full response)
    ↓
10. Generate embedding for assistant message
    ↓
11. Store in messages_embeddings
    ↓
12. Cache response (Redis + Qdrant)
```

### RAG Retrieval Implementation

```typescript
// app/server-trpc/src/services/rag-retrieval.ts
interface RetrievedContext {
  type: 'message' | 'file_chunk';
  id: string;
  text: string;
  score: number;
  metadata: Record<string, any>;
}

export async function retrieveContext(
  threadId: string,
  workspaceId: string,
  query: string,
  options: {
    messageLimit?: number;
    fileChunkLimit?: number;
    minScore?: number;
  } = {}
): Promise<RetrievedContext[]> {
  const { messageLimit = 3, fileChunkLimit = 5, minScore = 0.7 } = options;
  
  // 1. Get attached files
  const attachments = await db
    .select()
    .from(threadAttachments)
    .where(eq(threadAttachments.threadId, threadId));
  
  const fileIds = attachments.map((a) => a.fileId);
  
  // 2. Search messages (same thread)
  const messageContexts = await searchMessages(
    workspaceId,
    threadId,
    query,
    messageLimit
  );
  
  // 3. Search file chunks (attached files only)
  const fileContexts = fileIds.length > 0
    ? await searchFileChunks(workspaceId, fileIds, query, fileChunkLimit)
    : [];
  
  // 4. Combine and rank
  const allContexts: RetrievedContext[] = [
    ...messageContexts.map((m) => ({
      type: 'message' as const,
      id: m.messageId,
      text: m.text,
      score: m.score,
      metadata: { role: 'assistant' },
    })),
    ...fileContexts.map((f) => ({
      type: 'file_chunk' as const,
      id: f.chunkId,
      text: f.text,
      score: f.score,
      metadata: { fileId: f.fileId },
    })),
  ];
  
  // 5. Filter by min score and sort
  return allContexts
    .filter((c) => c.score >= minScore)
    .sort((a, b) => b.score - a.score);
}
```

### Context Prompt Building

```typescript
// app/server-trpc/src/services/prompt-builder.ts
export function buildRAGPrompt(
  userMessage: string,
  contexts: RetrievedContext[],
  conversationHistory: ChatMessage[]
): string {
  let prompt = `You are a helpful AI assistant. Use the following context to answer the user's question.\n\n`;
  
  // Add file chunks context
  const fileChunks = contexts.filter((c) => c.type === 'file_chunk');
  if (fileChunks.length > 0) {
    prompt += `## Context from Files:\n\n`;
    fileChunks.forEach((chunk, i) => {
      prompt += `[${i + 1}] ${chunk.text}\n\n`;
    });
  }
  
  // Add message history context
  const messageContexts = contexts.filter((c) => c.type === 'message');
  if (messageContexts.length > 0) {
    prompt += `## Relevant Previous Messages:\n\n`;
    messageContexts.forEach((msg, i) => {
      prompt += `[${i + 1}] ${msg.text}\n\n`;
    });
  }
  
  // Add conversation history
  prompt += `## Conversation History:\n\n`;
  conversationHistory.slice(-10).forEach((msg) => {
    prompt += `${msg.role === 'user' ? 'User' : 'Assistant'}: ${msg.text}\n\n`;
  });
  
  // Add current question
  prompt += `## Current Question:\n\n${userMessage}\n\n`;
  prompt += `Please provide a helpful answer based on the context above.`;
  
  return prompt;
}
```

---

## 7. Client Implementation Guide

### Flutter/Dart Structure

```
app/client-desktop/
├── lib/
│   ├── features/
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── chat_thread.dart
│   │   │   │   │   ├── chat_message.dart
│   │   │   │   │   └── model_config.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   ├── chat_repository.dart
│   │   │   │   │   └── chat_api_client.dart
│   │   │   │   └── local_cache/
│   │   │   │       └── chat_local_db.dart (SQLite/Isar)
│   │   │   ├── domain/
│   │   │   │   └── use_cases/
│   │   │   │       ├── create_thread.dart
│   │   │   │       ├── send_message.dart
│   │   │   │       └── stream_message.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── chat_thread_bloc.dart
│   │   │       │   └── chat_message_bloc.dart
│   │   │       └── widgets/
│   │   │           ├── thread_list.dart
│   │   │           ├── message_list.dart
│   │   │           └── message_input.dart
│   │   └── files/
│   │       ├── data/
│   │       │   └── file_repository.dart
│   │       └── presentation/
│   │           └── file_upload_widget.dart
```

### API Client Example

```dart
// lib/features/chat/data/repositories/chat_api_client.dart
class ChatApiClient {
  final String baseUrl;
  final String? authToken;
  
  Future<ChatThread> createThread({
    required String workspaceId,
    String? title,
    ModelConfig? modelConfig,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/threads'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'workspaceId': workspaceId,
        'title': title,
        'modelConfig': modelConfig?.toJson(),
      }),
    );
    
    if (response.statusCode == 201) {
      return ChatThread.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
  
  Stream<MessageStreamEvent> streamMessage(String messageId) {
    return _connectSSE('$baseUrl/messages/stream/$messageId');
  }
  
  Stream<MessageStreamEvent> _connectSSE(String url) async* {
    final request = http.Request('GET', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $authToken';
    
    final client = http.Client();
    final streamedResponse = await client.send(request);
    
    await for (final chunk in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (chunk.startsWith('data: ')) {
        final data = jsonDecode(chunk.substring(6));
        yield MessageStreamEvent.fromJson(data);
      }
    }
  }
}
```

### Local Cache Example

```dart
// lib/features/chat/data/local_cache/chat_local_db.dart
class ChatLocalDb {
  final Isar _isar;
  
  Future<void> cacheThread(ChatThread thread) async {
    await _isar.writeTxn(() async {
      await _isar.chatThreads.put(thread.toLocal());
    });
  }
  
  Future<List<ChatThread>> getCachedThreads(String workspaceId) async {
    return await _isar.chatThreads
        .filter()
        .workspaceIdEqualTo(workspaceId)
        .sortByUpdatedAtDesc()
        .limit(50)
        .findAll();
  }
  
  Future<void> cacheMessage(ChatMessage message) async {
    await _isar.writeTxn(() async {
      await _isar.chatMessages.put(message.toLocal());
    });
  }
  
  Future<List<ChatMessage>> getCachedMessages(String threadId) async {
    return await _isar.chatMessages
        .filter()
        .threadIdEqualTo(threadId)
        .sortByCreatedAtAsc()
        .findAll();
  }
}
```

### Bloc Example

```dart
// lib/features/chat/presentation/bloc/chat_message_bloc.dart
class ChatMessageBloc extends Bloc<ChatMessageEvent, ChatMessageState> {
  final ChatRepository _repository;
  
  ChatMessageBloc(this._repository) : super(ChatMessageInitial()) {
    on<SendMessage>(_onSendMessage);
    on<MessageStreamUpdate>(_onMessageStreamUpdate);
  }
  
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatMessageState> emit,
  ) async {
    emit(ChatMessageLoading());
    
    try {
      // 1. Create message (optimistic update)
      final message = await _repository.sendMessage(
        threadId: event.threadId,
        text: event.text,
      );
      
      emit(ChatMessageSent(message));
      
      // 2. Stream response
      await for (final streamEvent in _repository.streamMessage(message.id)) {
        if (streamEvent.type == 'delta') {
          emit(ChatMessageStreaming(streamEvent.text));
        } else if (streamEvent.type == 'done') {
          emit(ChatMessageCompleted(streamEvent.fullText));
        }
      }
    } catch (e) {
      emit(ChatMessageError(e.toString()));
    }
  }
  
  void _onMessageStreamUpdate(
    MessageStreamUpdate event,
    Emitter<ChatMessageState> emit,
  ) {
    if (state is ChatMessageStreaming) {
      final currentState = state as ChatMessageStreaming;
      emit(ChatMessageStreaming(
        currentState.text + event.delta,
      ));
    }
  }
}
```

---

## 8. Testing & Validation

### Unit Tests

```typescript
// app/server-trpc/src/routes/__tests__/threads.test.ts
describe('Threads API', () => {
  it('should create a thread', async () => {
    const response = await request(app)
      .post('/threads')
      .set('Authorization', `Bearer ${token}`)
      .send({
        workspaceId: 'test-workspace-id',
        title: 'Test Thread',
      });
    
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');
    expect(response.body.title).toBe('Test Thread');
  });
  
  it('should enforce RLS', async () => {
    const response = await request(app)
      .get('/threads')
      .set('Authorization', `Bearer ${unauthorizedToken}`);
    
    expect(response.status).toBe(403);
  });
});
```

### Integration Tests

```typescript
// app/server-trpc/src/integration/rag.test.ts
describe('RAG Integration', () => {
  it('should retrieve context from messages and files', async () => {
    // 1. Create thread
    // 2. Send messages
    // 3. Upload and attach file
    // 4. Wait for file processing
    // 5. Send query message
    // 6. Verify RAG context is included
  });
});
```

### E2E Tests

```typescript
// tests/e2e/chat-flow.test.ts
describe('Chat Flow E2E', () => {
  it('should complete full chat flow', async () => {
    // 1. Login
    // 2. Create workspace
    // 3. Create thread
    // 4. Send message
    // 5. Verify SSE stream
    // 6. Upload file
    // 7. Attach file to thread
    // 8. Send message with file context
    // 9. Verify RAG response
  });
});
```

---

## 9. Deployment Checklist

### Server

- [ ] Database migrations run
- [ ] Qdrant collections created
- [ ] Environment variables set (API keys, DB URLs)
- [ ] RLS policies tested
- [ ] Job workers running
- [ ] SSE endpoints tested
- [ ] Rate limiting configured
- [ ] Monitoring/Logging setup

### Client

- [ ] API base URL configured
- [ ] Authentication flow tested
- [ ] SSE reconnection logic
- [ ] Local cache working
- [ ] Error handling
- [ ] Offline mode tested

---

## 10. Next Steps

1. **Start with Priority 1** (Auth & Core)
   - Implement authentication
   - Set up RLS policies
   - Test workspace access

2. **Move to Priority 2** (Chat Core)
   - Replace in-memory stores with DB
   - Implement SSE streaming
   - Build basic UI

3. **Add Priority 3** (AI Orchestrator)
   - Integrate AI providers
   - Implement RAG
   - Add caching

4. **Complete Priority 4** (Files & RAG)
   - File upload flow
   - Chunking/embedding
   - RAG with files

5. **Finalize Priority 5** (Features)
   - Share/Export/Publish
   - Model presets

---

**Version:** 1.0.0  
**Last Updated:** 2025-01-XX  
**Status:** 🟢 Ready for Implementation

