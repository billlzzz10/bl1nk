import Fastify from 'fastify';
import cors from '@fastify/cors';
import sse from '@fastify/sse-v2';
import { z } from 'zod';
import { zChatThread, zChatMessage, zExportRequest } from './types/chat.js';

const app = Fastify({ logger: true });
await app.register(cors, { origin: true });
await app.register(sse);

app.get('/health', async () => ({ ok: true }));

// In-memory stub stores (replace with DB in Phase 2)
const threads = new Map<string, z.infer<typeof zChatThread>>();
const messages = new Map<string, z.infer<typeof zChatMessage>>();

// Threads
app.post('/threads', async (req, reply) => {
  const body = (req.body ?? {}) as any;
  const schema = z.object({
    workspaceId: z.string().uuid(),
    title: z.string().optional(),
    modelConfig: z.object({ provider: z.string(), modelId: z.string(), params: z.record(z.any()).optional() }).default({ provider: 'openai', modelId: 'gpt-4o-mini' }),
  });
  const input = schema.parse(body);
  const id = crypto.randomUUID();
  const now = Date.now();
  const th = { id, workspaceId: input.workspaceId, title: input.title, modelConfig: input.modelConfig, createdAt: now, updatedAt: now };
  const parsed = zChatThread.parse(th);
  threads.set(id, parsed);
  return reply.code(201).send(parsed);
});

app.get('/threads/:id', async (req, reply) => {
  const id = (req.params as any).id as string;
  const th = threads.get(id);
  if (!th) return reply.code(404).send({ error: 'Not found' });
  return th;
});

app.get('/threads', async (req) => {
  const { workspaceId } = (req.query as any) as { workspaceId?: string };
  const list = Array.from(threads.values()).filter((t) => !workspaceId || t.workspaceId === workspaceId);
  return list;
});

// Messages
app.post('/messages', async (req, reply) => {
  const schema = z.object({ threadId: z.string().uuid(), workspaceId: z.string().uuid(), text: z.string().min(1), parentId: z.string().uuid().optional(), meta: z.record(z.any()).optional() });
  const input = schema.parse((req.body ?? {}) as any);
  const id = crypto.randomUUID();
  const now = Date.now();
  const msg = zChatMessage.parse({ id, threadId: input.threadId, workspaceId: input.workspaceId, role: 'user', text: input.text, status: 'completed', meta: input.meta, parentId: input.parentId, createdAt: now });
  messages.set(id, msg);
  return reply.code(201).send({ messageId: id });
});

app.get('/messages', async (req) => {
  const { threadId } = (req.query as any) as { threadId?: string };
  const list = Array.from(messages.values()).filter((m) => !threadId || m.threadId === threadId);
  return list;
});

// SSE streaming demo (placeholder)
app.get('/messages/stream/:id', async (req, reply) => {
  const id = (req.params as any).id as string;
  reply.sse({ data: JSON.stringify({ id, delta: 'Hello', done: false }) });
  setTimeout(() => reply.sse({ data: JSON.stringify({ id, delta: ' world', done: false }) }), 200);
  setTimeout(() => reply.sse({ data: JSON.stringify({ id, done: true }) }), 400);
});

// Export job stub
app.post('/export', async (req, reply) => {
  const input = zExportRequest.parse((req.body ?? {}) as any);
  return reply.code(202).send({ jobId: crypto.randomUUID(), request: input });
});

const port = Number(process.env.PORT || 3333);
app.listen({ port, host: '0.0.0.0' }).then(() => app.log.info(`server listening on ${port}`));

