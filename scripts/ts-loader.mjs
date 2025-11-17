import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

export async function resolve(specifier, context, defaultResolve) {
  const resolution = await defaultResolve(specifier, context, defaultResolve);
  if (resolution.url.endsWith('.ts')) {
    return { ...resolution, format: 'module', shortCircuit: true };
  }
  return resolution;
}

export async function load(url, context, defaultLoad) {
  if (!url.endsWith('.ts')) {
    return defaultLoad(url, context, defaultLoad);
  }

  const filePath = fileURLToPath(url);
  
  // Security: Validate that the file path is within allowed directories
  const allowedDirs = ['scripts/', 'tests/'];
  const isAllowed = allowedDirs.some(dir => {
    const resolvedDir = path.resolve(process.cwd(), dir);
    const resolvedFile = path.resolve(filePath);
    return resolvedFile.startsWith(resolvedDir);
  });
  
  if (!isAllowed) {
    throw new Error(`Access denied: TypeScript files can only be loaded from: ${allowedDirs.join(', ')}`);
  }
  
  const source = await readFile(filePath, 'utf8');
  return { format: 'module', source, shortCircuit: true };
}
