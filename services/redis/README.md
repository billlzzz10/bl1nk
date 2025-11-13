# Redis Service

Redis service สำหรับ bl1nkOS - ใช้สำหรับ Exact Match Caching

## การใช้งาน

### เริ่มต้น Service

```bash
cd services/redis
docker-compose up -d
```

### ตรวจสอบสถานะ

```bash
docker-compose ps
docker-compose logs -f
```

### หยุด Service

```bash
docker-compose down
```

### ลบข้อมูลทั้งหมด

```bash
docker-compose down -v
```

## การเชื่อมต่อ

- **Host**: localhost
- **Port**: 6379
- **Connection String**: `redis://localhost:6379`

## Configuration

- **Max Memory**: 256MB
- **Eviction Policy**: allkeys-lru (ลบ key ที่ไม่ได้ใช้งานนานที่สุด)
- **Persistence**: AOF (Append Only File) enabled
- **Health Check**: ทุก 10 วินาที

## การใช้งานใน Application

```typescript
import { createClient } from 'redis';

const redis = createClient({
  url: 'redis://localhost:6379'
});

await redis.connect();

// Set cache
await redis.set('key', 'value', { EX: 3600 }); // TTL 1 hour

// Get cache
const value = await redis.get('key');

// Delete cache
await redis.del('key');
```

## Monitoring

```bash
# เข้า Redis CLI
docker exec -it bl1nk-redis redis-cli

# ตรวจสอบ memory usage
INFO memory

# ดู keys ทั้งหมด (ระวัง: ใช้เฉพาะ dev)
KEYS *

# ตรวจสอบจำนวน keys
DBSIZE
```
