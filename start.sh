#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Start Script — Run this every time you restart EC2
#  Usage: bash start.sh
# ═══════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Starting AWS DevOps Todo App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd ~/app

# Pull latest image and start
docker-compose pull
docker-compose up -d

# Wait for containers
sleep 5

# Show status
echo ""
docker ps
echo ""

# Test health
curl -s http://localhost/api/health
echo ""
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ App is live!"
echo "  🌍 http://$(curl -s ifconfig.me)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
