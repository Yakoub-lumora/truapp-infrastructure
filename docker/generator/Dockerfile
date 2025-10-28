# Multi-stage build for production Worker service
# Stage 1: Dependencies
FROM node:20.10.0-alpine AS deps
WORKDIR /app

# Install build dependencies for native modules (sharp, etc)
RUN apk add --no-cache libc6-compat python3 make g++

# Copy worker-specific package files
COPY package.worker.json package.json
COPY package-lock.worker.json package-lock.json

# Install production dependencies (tsx is now in dependencies, @types removed)
RUN npm ci --only=production --no-audit --no-fund && \
    npm cache clean --force

# Stage 2: Runtime (minimal final image)
FROM node:20.10.0-alpine AS runner
WORKDIR /app

# Install only runtime system dependencies
RUN apk add --no-cache dumb-init && \
    addgroup --system --gid 1001 worker && \
    adduser --system --uid 1001 worker

# Copy production node_modules (including tsx)
COPY --from=deps /app/node_modules ./node_modules

# Copy only worker-related source code
COPY lib/queue/ ./lib/queue/
COPY lib/services/ ./lib/services/
COPY lib/supabase/server.ts ./lib/supabase/server.ts
COPY lib/database.types.ts ./lib/database.types.ts
COPY lib/env.ts ./lib/env.ts
COPY lib/utils/log-context.ts ./lib/utils/log-context.ts
COPY lib/utils/edge-log-context.ts ./lib/utils/edge-log-context.ts
COPY tsconfig.json ./
COPY package.worker.json ./package.json

# Set ownership and switch to non-root user
RUN chown -R worker:worker /app
USER worker

# Environment
ENV NODE_ENV=production

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["npx", "tsx", "lib/queue/worker-service.ts", "start"]