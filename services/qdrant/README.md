# Qdrant Service

Qdrant vector database สำหรับ bl1nkOS - ใช้สำหรับ Semantic Search และ RAG

## การใช้งาน

### เริ่มต้น Service

```bash
cd services/qdrant
docker-compose up -d
```

### ตรวจสอบสถานะ

```bash
docker-compose ps
docker-compose logs -f
```

### หยุด Service

```bash
docker-compose down
```

### ลบข้อมูลทั้งหมด

```bash
docker-compose down -v
```

## การเชื่อมต่อ

- **HTTP API**: http://localhost:6333
- **gRPC API**: localhost:6334
- **Web UI**: http://localhost:6333/dashboard

## Collections

### 1. messages_embeddings

เก็บ Vector ของ Messages สำหรับ RAG

**Configuration:**
- Vector Size: 768 (Google Embeddings) หรือ 1024 (Voyage AI)
- Distance: Cosine
- Indexes: workspace_id, thread_id, created_at

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

### 2. file_chunks_embeddings

เก็บ Vector ของ File Chunks สำหรับ RAG

**Configuration:**
- Vector Size: 768 (Google Embeddings) หรือ 1024 (Voyage AI)
- Distance: Cosine
- Indexes: workspace_id, context_file_id, loader_type

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

## การใช้งานใน Application

```typescript
import { QdrantClient } from '@qdrant/js-client-rest';

const qdrant = new QdrantClient({
  url: 'http://localhost:6333',
  apiKey: process.env.QDRANT_API_KEY,
});

// Create collection
await qdrant.createCollection('messages_embeddings', {
  vectors: {
    size: 768,
    distance: 'Cosine',
  },
});

// Create payload index
await qdrant.createPayloadIndex('messages_embeddings', {
  field_name: 'workspace_id',
  field_schema: 'keyword',
});

// Insert vector
await qdrant.upsert('messages_embeddings', {
  wait: true,
  points: [{
    id: 'message-uuid',
    vector: [0.1, 0.2, ...], // 768 dimensions
    payload: {
      workspace_id: 'workspace-uuid',
      thread_id: 'thread-uuid',
      message_id: 'message-uuid',
      role: 'user',
      text: 'Sample message text...',
      created_at: new Date().toISOString(),
    },
  }],
});

// Search vectors
const results = await qdrant.search('messages_embeddings', {
  vector: queryVector,
  limit: 5,
  filter: {
    must: [
      { key: 'workspace_id', match: { value: 'workspace-uuid' } },
      { key: 'thread_id', match: { value: 'thread-uuid' } },
    ],
  },
});
```

## Initialization Script

สร้าง collections อัตโนมัติเมื่อเริ่มต้นระบบ:

```bash
# รันจาก root project
node scripts/init-qdrant.js
```

## Monitoring

```bash
# ตรวจสอบ collections
curl http://localhost:6333/collections

# ตรวจสอบ collection info
curl http://localhost:6333/collections/messages_embeddings

# ตรวจสอบจำนวน points
curl http://localhost:6333/collections/messages_embeddings/points/count
```

## Web Dashboard

เข้าถึง Qdrant Web UI ที่: http://localhost:6333/dashboard

Features:
- ดู collections และ points
- ทดสอบ vector search
- ตรวจสอบ cluster status
- Monitor performance metrics
