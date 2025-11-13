#!/usr/bin/env node

/**
 * Qdrant Collections Initialization Script
 * สร้าง collections และ indexes สำหรับ bl1nkOS
 */

import { QdrantClient } from '@qdrant/js-client-rest';

const QDRANT_URL = process.env.QDRANT_URL || 'http://localhost:6333';
const VECTOR_SIZE = parseInt(process.env.QDRANT_VECTOR_SIZE || '768', 10);

const client = new QdrantClient({ url: QDRANT_URL });

async function initializeCollections() {
  console.log('🚀 Initializing Qdrant collections...\n');

  try {
    // 1. Create messages_embeddings collection
    console.log('📝 Creating messages_embeddings collection...');
    try {
      await client.createCollection('messages_embeddings', {
        vectors: {
          size: VECTOR_SIZE,
          distance: 'Cosine',
        },
      });
      console.log('✅ messages_embeddings collection created');
    } catch (error) {
      if (error.message?.includes('already exists')) {
        console.log('ℹ️  messages_embeddings collection already exists');
      } else {
        throw error;
      }
    }

    // Create indexes for messages_embeddings
    console.log('📇 Creating indexes for messages_embeddings...');
    await client.createPayloadIndex('messages_embeddings', {
      field_name: 'workspace_id',
      field_schema: 'keyword',
    });
    await client.createPayloadIndex('messages_embeddings', {
      field_name: 'thread_id',
      field_schema: 'keyword',
    });
    await client.createPayloadIndex('messages_embeddings', {
      field_name: 'created_at',
      field_schema: 'datetime',
    });
    console.log('✅ Indexes created for messages_embeddings\n');

    // 2. Create file_chunks_embeddings collection
    console.log('📝 Creating file_chunks_embeddings collection...');
    try {
      await client.createCollection('file_chunks_embeddings', {
        vectors: {
          size: VECTOR_SIZE,
          distance: 'Cosine',
        },
      });
      console.log('✅ file_chunks_embeddings collection created');
    } catch (error) {
      if (error.message?.includes('already exists')) {
        console.log('ℹ️  file_chunks_embeddings collection already exists');
      } else {
        throw error;
      }
    }

    // Create indexes for file_chunks_embeddings
    console.log('📇 Creating indexes for file_chunks_embeddings...');
    await client.createPayloadIndex('file_chunks_embeddings', {
      field_name: 'workspace_id',
      field_schema: 'keyword',
    });
    await client.createPayloadIndex('file_chunks_embeddings', {
      field_name: 'context_file_id',
      field_schema: 'keyword',
    });
    await client.createPayloadIndex('file_chunks_embeddings', {
      field_name: 'loader_type',
      field_schema: 'keyword',
    });
    console.log('✅ Indexes created for file_chunks_embeddings\n');

    // Verify collections
    console.log('🔍 Verifying collections...');
    const collections = await client.getCollections();
    console.log('📊 Available collections:', collections.collections.map(c => c.name).join(', '));

    console.log('\n✨ Qdrant initialization completed successfully!');
  } catch (error) {
    console.error('❌ Error initializing Qdrant:', error.message);
    process.exit(1);
  }
}

initializeCollections();
