#!/usr/bin/env node
import { readFile, writeFile, access } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';

/**
 * @typedef {Object} ManagedFile
 * @property {string} path
 * @property {'json'|'markdown'} kind
 */

/** @type {readonly ManagedFile[]} */
export const MANAGED_FILES = Object.freeze([
  { path: 'constitution/system-map.json', kind: 'json' },
  { path: 'doc/operations/index.md', kind: 'markdown' },
  { path: 'doc/operations/metadata-maintenance.md', kind: 'markdown' }
]);

const MARKDOWN_METADATA_REGEX = /^<!--\s*metadata:\s*(\{[\s\S]*?\})\s*-->\s*\n*/i;

function createChecksum(input) {
  return createHash('sha256').update(input, 'utf8').digest('hex');
}

function sortValue(value) {
  if (Array.isArray(value)) {
    return value.map(sortValue);
  }

  if (value && typeof value === 'object') {
    const entries = Object.entries(value)
      .filter(([key]) => key !== 'metadata')
      .sort(([a], [b]) => a.localeCompare(b));

    return entries.reduce((acc, [key, val]) => {
      acc[key] = sortValue(val);
      return acc;
    }, {});
  }

  return value;
}

function isRecord(value) {
  return Boolean(value) && typeof value === 'object' && !Array.isArray(value);
}

function normaliseJsonForChecksum(data) {
  return JSON.stringify(sortValue(data));
}

function parseCliArgs(argv) {
  const options = { dryRun: false };
  const includePaths = new Set();

  for (const rawArg of argv) {
    if (!rawArg.startsWith('--')) {
      throw new Error(`Unexpected argument: ${rawArg}`);
    }

    const [flag, value] = rawArg.split('=');
    switch (flag) {
      case '--dry-run':
        if (value !== undefined && value !== 'true' && value !== 'false') {
          throw new Error('--dry-run does not accept a value; use --dry-run or omit the flag');
        }
        options.dryRun = value === 'false' ? false : true;
        break;
      case '--path':
        if (!value) {
          throw new Error('--path requires a value, e.g. --path=constitution/system-map.json');
        }
        // Prevent path traversal attacks
        if (value.includes('..') || path.isAbsolute(value)) {
          throw new Error('--path must be a relative path without ".." segments');
        }
        includePaths.add(value);
        break;
      case '--paths':
        if (!value) {
          throw new Error('--paths requires a comma-separated list of values');
        }
        value.split(',').forEach((item) => {
          const trimmed = item.trim();
          if (trimmed) {
            // Prevent path traversal attacks
            if (trimmed.includes('..') || path.isAbsolute(trimmed)) {
              throw new Error('--paths must contain relative paths without ".." segments');
            }
            includePaths.add(trimmed);
          }
        });
        });
        break;
      default:
        throw new Error(`Unknown option: ${flag}`);
    }
  }

  if (includePaths.size > 0) {
    options.includePaths = includePaths;
  }

  return options;
}

function validatePaths(includePaths, managedFiles) {
  const managedPaths = new Set(managedFiles.map((file) => file.path));
  const unknown = Array.from(includePaths).filter((filePath) => !managedPaths.has(filePath));
  if (unknown.length > 0) {
    throw new Error(`Unknown managed path(s): ${unknown.join(', ')}`);
  }
}

function formatMarkdownMetadata(metadata) {
  return `<!-- metadata: ${JSON.stringify(metadata, null, 2)} -->\n\n`;
}

function removeMarkdownMetadataBlock(content) {
  const match = content.match(MARKDOWN_METADATA_REGEX);
  if (!match) {
    return { metadata: null, body: content };
  }

  let metadata = null;
  try {
    metadata = JSON.parse(match[1]);
  } catch (error) {
    throw new Error('Failed to parse metadata JSON from markdown file');
  }

  const body = content.slice(match[0].length);
  return { metadata, body };
}

function ensureTrailingNewline(value) {
  return value.endsWith('\n') ? value : `${value}\n`;
}

export async function updateSystemMetadata(options = {}) {
  const { dryRun = false, includePaths, rootDir = process.cwd(), timestamp } = options;
  const includeSet = includePaths ? new Set(includePaths) : undefined;

  if (includeSet) {
    validatePaths(includeSet, MANAGED_FILES);
  }

  const summaries = [];

  for (const file of MANAGED_FILES) {
    if (includeSet && !includeSet.has(file.path)) {
      summaries.push({ path: file.path, updated: false, skipped: true, reason: 'Filtered out by --path(s)' });
      continue;
    }

    const absolutePath = path.resolve(rootDir, file.path);
    try {
      await access(absolutePath);
    } catch (error) {
      summaries.push({ path: file.path, updated: false, skipped: true, reason: 'File not found' });
      continue;
    }

    const originalContent = await readFile(absolutePath, 'utf8');
    let nextContent = null;

    if (file.kind === 'json') {
      let parsed;
      try {
        parsed = JSON.parse(originalContent);
      } catch (error) {
        throw new Error(`Unable to parse JSON in ${file.path}: ${error.message}`);
      }

      if (!isRecord(parsed)) {
        throw new Error(`JSON metadata target ${file.path} must contain a top-level object`);
      }

      const metadataRecord = isRecord(parsed.metadata) ? { ...parsed.metadata } : {};
      const clone = structuredClone(parsed);
      if (isRecord(clone)) {
        delete clone.metadata;
      }

      const checksum = createChecksum(normaliseJsonForChecksum(clone));
      const isoTimestamp = timestamp ?? new Date().toISOString();
      metadataRecord.checksum = checksum;
      metadataRecord.updated = isoTimestamp;

      const updatedObject = { ...parsed, metadata: metadataRecord };
      nextContent = `${JSON.stringify(updatedObject, null, 2)}\n`;
    } else if (file.kind === 'markdown') {
      const { metadata: existingMetadata, body } = removeMarkdownMetadataBlock(originalContent);
      const checksum = createChecksum(body);
      const isoTimestamp = timestamp ?? new Date().toISOString();
      const metadata = {
        ...(existingMetadata ?? {}),
        checksum,
        updated: isoTimestamp
      };

      const bodyContent = body.trimStart();
      const prefix = bodyContent.length > 0 && !bodyContent.startsWith('\n') ? '\n' : '';
      nextContent = ensureTrailingNewline(`${formatMarkdownMetadata(metadata)}${prefix}${bodyContent}`);
    } else {
      throw new Error(`Unsupported file kind: ${String(file.kind)}`);
    }

    if (nextContent !== null && nextContent !== originalContent) {
      if (!dryRun) {
        await writeFile(absolutePath, nextContent, 'utf8');
      }
      summaries.push({ path: file.path, updated: true, skipped: false });
    } else {
      summaries.push({ path: file.path, updated: false, skipped: false, reason: 'No changes required' });
    }
  }

  return summaries;
}

async function runFromCli() {
  try {
    const cliOptions = parseCliArgs(process.argv.slice(2));
    const summaries = await updateSystemMetadata({
      dryRun: cliOptions.dryRun,
      includePaths: cliOptions.includePaths,
      rootDir: process.cwd()
    });

    if (summaries.length === 0) {
      console.log('No managed files configured.');
      return;
    }

    for (const summary of summaries) {
      if (summary.updated) {
        console.log(`✅ Updated metadata for ${summary.path}`);
      } else if (summary.skipped) {
        console.log(`⚠️  Skipped ${summary.path}${summary.reason ? ` – ${summary.reason}` : ''}`);
      } else {
        console.log(`ℹ️  No changes for ${summary.path}`);
      }
    }
  } catch (error) {
    console.error(`Metadata update failed: ${error.message}`);
    process.exitCode = 1;
  }
}

const scriptPath = fileURLToPath(import.meta.url);
if (process.argv[1] && path.resolve(process.argv[1]) === scriptPath) {
  void runFromCli();
}
