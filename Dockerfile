# ── Base Image ────────────────────────────────────────
FROM node:18-alpine

# Label metadata
LABEL maintainer="chandangadewar@gmail.com"
LABEL version="1.0.0"
LABEL description="Dockerized Todo App — AWS DevOps Project"

# ── Set working directory ─────────────────────────────
WORKDIR /app

# ── Install dependencies (layer cache optimization) ───
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

# ── Copy application code ─────────────────────────────
COPY . .

# ── Create non-root user (security best practice) ─────
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# ── Expose port ───────────────────────────────────────
EXPOSE 3000

# ── Environment defaults ──────────────────────────────
ENV NODE_ENV=production \
    PORT=3000

# ── Health Check using node (no wget needed) ──────────
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1) }).on('error', () => process.exit(1))"

# ── Start the app ─────────────────────────────────────
CMD ["node", "server.js"]
