# Project Status and Plan

## Overview
This document summarizes completed work, the merged Blueprint (A–D), the 40/60 split, and the prioritized roadmap to connect Client and Server.

## Completed
- Desktop MVP (Electron) at Flutter baseline; flags: ENABLE_SHARE_UI, ENABLE_CHAT_UI.
- GPU disabled on WSL to avoid viz errors.
- Contributor guide (AGENTS.md) and README updates.
- Server scaffold (Fastify + Zod) with `/health`, `/threads`, `/messages`, SSE demo.
- DB migrations v1 for Accounts/Workspaces/Members; Threads/Messages/Context/Attachments; Share/Publish/ExportJobs; Jobs.
- CI: Flutter analyze/tests; Server typecheck.

## Blueprint (Merged)
- A Business: Accounts, Workspaces, Members, Subscriptions, RLS/ACL.
- B Chat/File: Threads, Messages (pending/streaming/completed/error), ContextFiles, Thread_Attachments.
- C Vector: Qdrant collections (messages_embeddings, file_chunks_embeddings).
- D Orchestration: Async Jobs (export, publish, file_chunking, file_embedding, reindex).

## 40/60 Split
- Client (40%): UI/state, local cache, session, start uploads (signed URL), markdown render, API calls.
- Server (60%): Auth+RLS, persistence, SSE streaming, file processing, RAG, jobs, quotas.

## Connection Priorities
1) Auth/Core → register/login; list workspaces.
2) Chat Core → threads/messages (GET/POST), SSE hello.
3) AI Orchestrator → real stream; state machine; idempotency.
4) File & RAG → files/attachments + jobs; chunk/embed/retrieve.
5) Features → share/export/publish; model-presets.

## Dev Commands
- Desktop: app/client-desktop → `npm run dev|dev:all` / `npm run build:all && npm start`.
- Server: app/server-trpc → `npm install && npm run dev`; `npm run typecheck`.

