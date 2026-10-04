#!/bin/bash
# ═══════════════════════════════════════════════════════
#  DALLOL BOOKING — ONE CLICK START
#  Run:  bash START.sh
# ═══════════════════════════════════════════════════════
set -e
cd "$(dirname "$0")/booking_website"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         DALLOL BOOKING SYSTEM — STARTING UP             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Start PostgreSQL if not running
sudo service postgresql start 2>/dev/null || true
sleep 1

# Test DB connection
echo "→ Checking database..."
PGPASSWORD=dallolapp2024 psql -h 127.0.0.1 -U dallol_app -d dallol_booking \
  -t -c "SELECT COUNT(*) FROM hotels;" > /dev/null 2>&1 \
  && echo "  ✅  Database OK" \
  || { echo "  ❌  DB failed — resetting password..."; \
       sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'dallol2024';"; \
       PGPASSWORD=dallol2024 psql -h 127.0.0.1 -U postgres -d dallol_booking \
         -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dallol_app; GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dallol_app;" 2>/dev/null; }

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║   ✅  DALLOL BOOKING IS LIVE!                             ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║                                                          ║"
echo "║  🌐  http://localhost:8080          Guest Website        ║"
echo "║  🔐  http://localhost:8080/admin/login   Admin Panel     ║"
echo "║                                                          ║"
echo "║  ADMIN LOGINS:                                           ║"
echo "║  👑 superadmin@dalloltech.com  / Admin@1234              ║"
echo "║  🏙️  subadmin.addis@dalloltech.com / SubAdmin@1234       ║"
echo "║  🤝 broker1.addis@dalloltech.com / Broker@1234           ║"
echo "║  🏨 manager.sheraton@dalloltech.com / Manager@1234       ║"
echo "║                                                          ║"
echo "║  Press Ctrl+C to stop                                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

php spark serve --host 0.0.0.0 --port 8080
