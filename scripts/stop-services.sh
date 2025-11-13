#!/bin/bash

# bl1nkOS Services Stop Script

echo "🛑 Stopping bl1nkOS Services..."

docker-compose down

echo "✅ All services stopped"
