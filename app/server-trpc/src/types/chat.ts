import { z } from 'zod';

export const zModelConfig = z.object({
  provider: z.string(),
  modelId: z.string(),
  params: z.record(z.any()).optional(),
});
export type ModelConfig = z.infer<typeof zModelConfig>;

export const zChatThread = z.object({
  id: z.string().uuid(),
  workspaceId: z.string().uuid(),
  title: z.string().optional(),
  modelConfig: zModelConfig,
  createdAt: z.number(),
  updatedAt: z.number(),
});
export type ChatThread = z.infer<typeof zChatThread>;

export const zMessageStatus = z.enum(['pending', 'streaming', 'completed', 'error']);
export const zMessageRole = z.enum(['user', 'assistant']);

export const zChatMessage = z.object({
  id: z.string().uuid(),
  threadId: z.string().uuid(),
  workspaceId: z.string().uuid(),
  role: zMessageRole,
  text: z.string().min(1).max(10000), // Adjust max length as needed
  status: zMessageStatus,
  meta: z.record(z.any()).optional(),
  parentId: z.string().uuid().optional(),
  createdAt: z.number(),
});
export type ChatMessage = z.infer<typeof zChatMessage>;

