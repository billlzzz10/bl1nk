import { z } from 'zod';

export const zVisibility = z.enum(['private', 'workspace', 'public', 'url']);
export const zShareState = z.object({
  entityId: z.string().uuid(),
  visibility: zVisibility,
  slug: z.string().optional(),
  url: z.string().url().optional(),
  permissions: z.array(z.enum(['view', 'comment', 'edit'])).optional(),
  updatedAt: z.number().optional(),
});
export type ShareState = z.infer<typeof zShareState>;

export const zPublishState = z.object({
  entityId: z.string().uuid(),
  status: z.enum(['draft', 'published', 'unpublished']),
  slug: z.string().optional(),
  lastPublishedAt: z.number().optional(),
});
export type PublishState = z.infer<typeof zPublishState>;

export const zExportRequest = z.object({
  threadId: z.string().uuid(),
  format: z.enum(['pdf', 'markdown', 'txt']),
  options: z.record(z.any()).optional(),
});
export type ExportRequest = z.infer<typeof zExportRequest>;

