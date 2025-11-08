import { z } from 'zod';

export const zLoaderType = z.enum(['pdf', 'txt', 'markdown', 'unknown']);
export const zSourceType = z.enum(['upload', 'web']);

export const zContextFile = z.object({
  id: z.string().uuid(),
  workspaceId: z.string().uuid(),
  name: z.string(),
  sourceType: zSourceType,
  loaderType: zLoaderType,
  path: z.string().optional(),
  url: z.string().url().optional(),
  hash: z.string().optional(),
  status: z.enum(['uploading', 'pending_chunks', 'ready', 'error']),
  createdAt: z.number(),
});
export type ContextFile = z.infer<typeof zContextFile>;

export const zThreadAttachment = z.object({
  threadId: z.string().uuid(),
  fileId: z.string().uuid(),
  addedAt: z.number(),
});
export type ThreadAttachment = z.infer<typeof zThreadAttachment>;

