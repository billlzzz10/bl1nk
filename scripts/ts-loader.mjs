import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

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

  const source = await readFile(fileURLToPath(url), 'utf8');
  return { format: 'module', source, shortCircuit: true };
}
