# Desktop App Build & Deployment Guide

Complete guide for building and deploying the bl1nk Desktop application.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Development Workflow](#development-workflow)
4. [Building for Production](#building-for-production)
5. [Services Integration](#services-integration)
6. [Troubleshooting](#troubleshooting)
7. [CI/CD Integration](#cicd-integration)

---

## Prerequisites

### Required Software

- **Node.js**: v18.0.0 or higher
- **npm**: v9.0.0 or higher
- **Docker**: Latest version (for Redis and Qdrant)
- **Git**: For version control

### Windows-Specific Requirements

For building Windows executables:
- Windows 10/11 or Windows Server 2019+
- Visual Studio Build Tools (optional, for native modules)

---

## Initial Setup

### 1. Clone and Install Dependencies

```bash
# Clone repository
git clone <repository-url>
cd bl1nk

# Install root dependencies
npm install

# Install desktop app dependencies
cd app/client-desktop
npm install
cd ../..
```

### 2. Start Services (Redis & Qdrant)

```bash
# Start Redis and Qdrant with Docker Compose
npm run services:start

# Wait for services to be ready (about 5-10 seconds)
# You should see:
# ✅ Redis is ready
# ✅ Qdrant is ready
```

### 3. Initialize Qdrant Collections

```bash
# Create vector collections for RAG
npm run services:init

# You should see:
# ✅ messages_embeddings collection created
# ✅ file_chunks_embeddings collection created
```

### 4. Verify Services

```bash
# Check Redis
docker exec bl1nk-redis redis-cli ping
# Expected: PONG

# Check Qdrant
curl http://localhost:6333/healthz
# Expected: {"status":"ok"}

# View Qdrant Dashboard
# Open: http://localhost:6333/dashboard
```

---

## Development Workflow

### Running in Development Mode

```bash
# Option 1: Run from root
npm run desktop:dev

# Option 2: Run from desktop directory
cd app/client-desktop
npm run dev
```

### With Feature Flags

```bash
# Enable all features
cd app/client-desktop
cross-env ENABLE_SHARE_UI=true ENABLE_CHAT_UI=true npm run dev

# Enable only chat
cross-env ENABLE_CHAT_UI=true npm run dev
```

### Development Features

- **Hot Reload**: TypeScript files are watched and recompiled automatically
- **Auto Restart**: Electron restarts when main process changes
- **DevTools**: Opens automatically in development mode
- **Source Maps**: Full debugging support

---

## Building for Production

### Build TypeScript Only

```bash
cd app/client-desktop
npm run build

# Output: dist/ directory with compiled JavaScript
```

### Create Distributable Packages

#### Windows Installer (NSIS)

```bash
cd app/client-desktop
npm run dist:win

# Creates:
# - release/bl1nk Desktop-0.1.0-x64.exe (64-bit installer)
# - release/bl1nk Desktop-0.1.0-ia32.exe (32-bit installer)
```

#### Portable Executable

```bash
cd app/client-desktop
npm run dist:portable

# Creates:
# - release/bl1nk Desktop-0.1.0-portable.exe (no installation required)
```

#### All Architectures

```bash
cd app/client-desktop
npm run dist:all

# Creates installers and portable versions for both x64 and ia32
```

### Build Artifacts

After building, you'll find artifacts in `app/client-desktop/release/`:

```
release/
├── bl1nk Desktop-0.1.0-x64.exe          # 64-bit installer
├── bl1nk Desktop-0.1.0-ia32.exe         # 32-bit installer
├── bl1nk Desktop-0.1.0-portable.exe     # Portable version
├── win-unpacked/                         # Unpacked application (for testing)
│   ├── bl1nk Desktop.exe
│   ├── resources/
│   └── ...
└── builder-debug.yml                     # Build metadata
```

### Build Configuration

Build settings are in `app/client-desktop/package.json`:

```json
{
  "build": {
    "appId": "com.bl1nk.desktop",
    "productName": "bl1nk Desktop",
    "win": {
      "target": ["nsis", "portable"],
      "icon": "build/icon.ico"
    },
    "nsis": {
      "oneClick": false,
      "allowToChangeInstallationDirectory": true,
      "createDesktopShortcut": true
    }
  }
}
```

---

## Services Integration

### Architecture Overview

```
┌─────────────────────┐
│  Desktop App        │
│  (Electron)         │
└──────────┬──────────┘
           │
           ├─────────────────┐
           │                 │
           ▼                 ▼
    ┌──────────┐      ┌──────────┐
    │  Redis   │      │  Qdrant  │
    │  :6379   │      │  :6333   │
    └──────────┘      └──────────┘
           │                 │
           └────────┬────────┘
                    │
                    ▼
           ┌─────────────────┐
           │  Backend Server │
           │  (tRPC/Express) │
           └─────────────────┘
```

### Redis Integration

**Purpose**: Exact match caching for AI responses

```typescript
// Configuration
REDIS_URL=redis://localhost:6379

// Usage in app
const redis = createClient({ url: process.env.REDIS_URL });
await redis.connect();

// Cache AI response
await redis.set(`cache:${queryHash}`, response, { EX: 3600 });

// Retrieve cached response
const cached = await redis.get(`cache:${queryHash}`);
```

### Qdrant Integration

**Purpose**: Semantic search and RAG

```typescript
// Configuration
QDRANT_URL=http://localhost:6333

// Usage in app
import { QdrantClient } from '@qdrant/js-client-rest';

const qdrant = new QdrantClient({ url: process.env.QDRANT_URL });

// Search for similar messages
const results = await qdrant.search('messages_embeddings', {
  vector: queryEmbedding,
  limit: 5,
  filter: {
    must: [
      { key: 'workspace_id', match: { value: workspaceId } },
      { key: 'thread_id', match: { value: threadId } },
    ],
  },
});
```

### Service Health Checks

```bash
# Check all services
docker-compose ps

# View logs
docker-compose logs -f redis
docker-compose logs -f qdrant

# Restart services
docker-compose restart

# Stop services
npm run services:stop
```

---

## Troubleshooting

### Build Errors

#### Error: "Cannot find module 'electron'"

```bash
cd app/client-desktop
rm -rf node_modules package-lock.json
npm install
```

#### Error: "TypeScript compilation failed"

```bash
# Check TypeScript errors
cd app/client-desktop
npx tsc --noEmit

# Fix and rebuild
npm run build
```

#### Error: "electron-builder failed"

```bash
# Clear electron-builder cache
rm -rf ~/AppData/Local/electron-builder/Cache  # Windows
rm -rf ~/.cache/electron-builder               # Linux/Mac

# Rebuild
npm run dist:win
```

### Runtime Errors

#### Services Not Connecting

```bash
# Check if services are running
docker ps | grep bl1nk

# Restart services
npm run services:stop
npm run services:start

# Check logs
docker-compose logs
```

#### "Failed to fetch" Errors

```bash
# Verify backend server is running
curl http://localhost:3333/health

# Check API_BASE_URL in .env
cat app/client-desktop/.env
```

### Development Issues

#### Hot Reload Not Working

```bash
# Kill all Electron processes
pkill -f electron  # Linux/Mac
taskkill /F /IM electron.exe  # Windows

# Restart dev server
npm run dev
```

#### DevTools Not Opening

```bash
# Set NODE_ENV explicitly
cross-env NODE_ENV=development npm run dev
```

---

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/build-desktop.yml`:

```yaml
name: Build Desktop App

on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main]

jobs:
  build-windows:
    runs-on: windows-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: |
          npm install
          cd app/client-desktop
          npm install
          
      - name: Build TypeScript
        run: |
          cd app/client-desktop
          npm run build
          
      - name: Build Windows artifacts
        run: |
          cd app/client-desktop
          npm run dist:win
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: windows-installers
          path: |
            app/client-desktop/release/*.exe
            app/client-desktop/release/*.yml
          
      - name: Create Release
        if: startsWith(github.ref, 'refs/tags/v')
        uses: softprops/action-gh-release@v1
        with:
          files: |
            app/client-desktop/release/*.exe
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Build Scripts

Create `scripts/build-desktop.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Building bl1nk Desktop..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install
cd app/client-desktop
npm install

# Build TypeScript
echo "🔨 Building TypeScript..."
npm run build

# Create distributables
echo "📦 Creating Windows installers..."
npm run dist:win

echo "✅ Build complete!"
echo "📁 Artifacts: app/client-desktop/release/"
```

### Automated Testing

```bash
# Add to package.json scripts
"test:desktop": "cd app/client-desktop && npm test",
"test:e2e": "cd app/client-desktop && npm run test:e2e"
```

---

## Release Checklist

Before releasing a new version:

- [ ] Update version in `app/client-desktop/package.json`
- [ ] Update CHANGELOG.md
- [ ] Test all features with `ENABLE_CHAT_UI=true`
- [ ] Build and test installers
- [ ] Verify services integration (Redis, Qdrant)
- [ ] Test on clean Windows installation
- [ ] Create Git tag: `git tag v0.1.0`
- [ ] Push tag: `git push origin v0.1.0`
- [ ] Upload artifacts to GitHub Releases

---

## Performance Optimization

### Build Size Optimization

```json
// In package.json build config
{
  "build": {
    "compression": "maximum",
    "asar": true,
    "files": [
      "dist/**/*",
      "!dist/**/*.map"
    ]
  }
}
```

### Runtime Optimization

- Enable production mode: `NODE_ENV=production`
- Use code splitting for large modules
- Implement lazy loading for heavy components
- Cache API responses locally

---

## Support

For issues and questions:

- GitHub Issues: [repository-url]/issues
- Documentation: `doc/` directory
- Community: [Discord/Slack link]

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-13  
**Status**: 🟢 Production Ready
