import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, readFile, mkdir } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { updateSystemMetadata } from '../../scripts/update-system-metadata.ts';

const FIXED_TIMESTAMP = '2024-01-01T00:00:00.000Z';

async function createTempRoot() {
  return mkdtemp(path.join(tmpdir(), 'metadata-test-'));
}

async function writeRelative(root, relativePath, contents) {
  const absolute = path.join(root, relativePath);
  await mkdir(path.dirname(absolute), { recursive: true });
  await writeFile(absolute, contents, 'utf8');
  return absolute;
}

function sortValue(value) {
  if (Array.isArray(value)) {
    return value.map(sortValue);
  }

  if (value && typeof value === 'object') {
    return Object.keys(value)
      .sort((a, b) => a.localeCompare(b))
      .reduce((acc, key) => {
        acc[key] = sortValue(value[key]);
        return acc;
      }, {});
  }

  return value;
}

test('updates JSON metadata with deterministic checksum', async () => {
  const root = await createTempRoot();
  const relativePath = 'constitution/system-map.json';
  const payload = {
    description: 'Example',
    domains: [{ id: 'alpha', summary: 'demo' }]
  };
  await writeRelative(root, relativePath, `${JSON.stringify(payload, null, 2)}\n`);

  const summaries = await updateSystemMetadata({
    rootDir: root,
    timestamp: FIXED_TIMESTAMP,
    includePaths: new Set([relativePath])
  });

  const result = summaries.find((entry) => entry.path === relativePath);
  assert.ok(result, 'Summary for JSON file missing');
  assert.equal(result.updated, true);

  const updatedContent = await readFile(path.join(root, relativePath), 'utf8');
  const updatedJson = JSON.parse(updatedContent);
  assert.ok(updatedJson.metadata, 'Metadata block missing in JSON file');
  assert.equal(updatedJson.metadata.updated, FIXED_TIMESTAMP);

  const cloned = JSON.parse(JSON.stringify(updatedJson));
  delete cloned.metadata;
  const expectedChecksum = createHash('sha256')
    .update(JSON.stringify(sortValue(cloned)))
    .digest('hex');
  assert.equal(updatedJson.metadata.checksum, expectedChecksum);
});

test('adds metadata comment to markdown body', async () => {
  const root = await createTempRoot();
  const relativePath = 'doc/operations/index.md';
  const body = '# Operations\\n\\n- item\\n';
  await writeRelative(root, relativePath, body);

  const summaries = await updateSystemMetadata({
    rootDir: root,
    timestamp: FIXED_TIMESTAMP,
    includePaths: new Set([relativePath])
  });

  const result = summaries.find((entry) => entry.path === relativePath);
  assert.ok(result);
  assert.equal(result.updated, true);

  const updatedContent = await readFile(path.join(root, relativePath), 'utf8');
  const match = updatedContent.match(/^<!--\s*metadata:\s*(\{[\s\S]*?\})\s*-->\s*\n*/i);
  assert.ok(match, 'Metadata comment missing');
  const metadata = JSON.parse(match[1]);
  assert.equal(metadata.updated, FIXED_TIMESTAMP);

  const bodyWithoutMetadata = updatedContent.slice(match[0].length);
  assert.equal(bodyWithoutMetadata, `${body}\n`);
  const expectedChecksum = createHash('sha256').update(body).digest('hex');
  assert.equal(metadata.checksum, expectedChecksum);
});

test('dry-run reports updates without writing to disk', async () => {
  const root = await createTempRoot();
  const relativePath = 'doc/operations/metadata-maintenance.md';
  const body = '# Metadata Guide\\n';
  const absolute = await writeRelative(root, relativePath, body);

  const summaries = await updateSystemMetadata({
    rootDir: root,
    timestamp: FIXED_TIMESTAMP,
    includePaths: new Set([relativePath]),
    dryRun: true
  });

  const result = summaries.find((entry) => entry.path === relativePath);
  assert.ok(result);
  assert.equal(result.updated, true);

  const afterContent = await readFile(absolute, 'utf8');
  assert.equal(afterContent, body, 'Dry-run should not mutate file contents');
});

test('throws when includePaths contains unknown target', async () => {
  await assert.rejects(
    () =>
      updateSystemMetadata({
        includePaths: new Set(['does/not/exist'])
      }),
    /Unknown managed path/
  );
});
