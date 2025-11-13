# bl1nk Desktop

Windows Desktop application for bl1nkOS - AI Agent Management Platform

## Features

- 🤖 AI Chat with multiple model support (GPT-4, Claude, Gemini)
- 💬 Conversation management with thread history
- 🎨 Modern, dark-themed UI
- 🔄 Real-time streaming responses (SSE)
- 💾 Local data persistence
- 🔌 Redis and Qdrant integration for caching and RAG

## Development

### Prerequisites

- Node.js 18+ and npm
- Docker (for Redis and Qdrant services)

### Installation

```bash
cd app/client-desktop
npm install
```

### Running in Development

```bash
# Start with all features enabled
cross-env ENABLE_SHARE_UI=true ENABLE_CHAT_UI=true npm run dev

# Or just chat features
cross-env ENABLE_CHAT_UI=true npm run dev

# Default (features disabled)
npm run dev
```

### Building

```bash
# Build TypeScript
npm run build

# Run built app
npm start
```

## Production Build

### Create Distributable Packages

```bash
# Build for Windows (NSIS installer + portable)
npm run dist:win

# Build portable version only
npm run dist:portable

# Build for all architectures (x64 + ia32)
npm run dist:all

# Package without creating installer (for testing)
npm run package
```

### Build Artifacts

Artifacts are created in the `release/` directory:

- **NSIS Installer**: `bl1nk Desktop-0.1.0-x64.exe` (installable)
- **Portable**: `bl1nk Desktop-0.1.0-portable.exe` (no installation required)
- **Unpacked**: `release/win-unpacked/` (for testing)

## Feature Flags

Control features via environment variables:

- `ENABLE_SHARE_UI=true` - Enable Share/Export/Publish menu
- `ENABLE_CHAT_UI=true` - Enable chat functionality
- `API_BASE_URL` - Backend API URL (default: http://localhost:3333)
- `REDIS_URL` - Redis connection URL (default: redis://localhost:6379)
- `QDRANT_URL` - Qdrant URL (default: http://localhost:6333)

## Architecture

### Tech Stack

- **Electron**: Desktop application framework
- **TypeScript**: Type-safe development
- **IPC**: Secure communication between main and renderer processes
- **Local Storage**: Offline-first data persistence

### Project Structure

```
app/client-desktop/
├── src/
│   ├── main.ts              # Main process (Electron)
│   ├── preload.ts           # Preload script (IPC bridge)
│   ├── types.ts             # TypeScript type definitions
│   ├── api-client.ts        # API client for backend communication
│   └── renderer/
│       ├── index.html       # Main HTML
│       ├── styles.css       # Application styles
│       ├── renderer.ts      # Renderer entry point
│       └── app.ts           # Main application logic
├── dist/                    # Compiled JavaScript
├── release/                 # Build artifacts
├── build/                   # Build resources (icons, etc.)
├── package.json
└── tsconfig.json
```

## API Integration

The desktop app connects to the bl1nk backend server for:

- **Authentication**: User login and session management
- **Workspaces**: Multi-workspace support
- **Threads**: Conversation management
- **Messages**: Chat message CRUD and streaming
- **Files**: Context file upload and RAG

See `src/api-client.ts` for full API documentation.

## Services Integration

### Redis (Caching)

Used for exact match caching to reduce AI API costs.

```typescript
// Configured via environment
REDIS_URL=redis://localhost:6379
```

### Qdrant (Vector Search)

Used for semantic search and RAG capabilities.

```typescript
// Configured via environment
QDRANT_URL=http://localhost:6333
```

## Troubleshooting

### Build Issues

```bash
# Clean build
rm -rf dist/ release/
npm run build
```

### Development Issues

```bash
# Clear Electron cache
rm -rf ~/.electron
npm install
```

### Services Not Running

```bash
# Start Redis and Qdrant
cd ../..
docker-compose up -d

# Check status
docker-compose ps
```

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for development guidelines.

## License

See [LICENSE.md](../../LICENSE.md)
