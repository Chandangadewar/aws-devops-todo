# ── Base Image ────────────────────────────────────────
FROM node:18-alpine

# Label metadata (best practice)
LABEL maintainer="your-email@gmail.com"
LABEL version="1.0.0"
LABEL description="Dockerized Todo App — AWS DevOps Project"

# ── Set working directory ─────────────────────────────
WORKDIR /app

# ── Install dependencies first (layer cache optimization) ──
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

# ── Health Check (critical for Docker & AWS) ──────────
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

# ── Start the app ─────────────────────────────────────
CMD ["node", "server.js"]
