#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  Dallol Booking — One-Click Fix & Run Script
#  Run this script once after every system restart:
#    bash fix_and_run.sh
# ═══════════════════════════════════════════════════════════════

set -e
cd "$(dirname "$0")"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║         DALLOL BOOKING — FIX & RUN                      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Step 1: Make sure PostgreSQL is running ──────────────────────
echo "▶ Step 1: Starting PostgreSQL..."
sudo service postgresql start 2>/dev/null || true
sleep 2

# ── Step 2: Reset postgres password ─────────────────────────────
echo "▶ Step 2: Resetting database password..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'dallol2024';" 2>&1

# ── Step 3: Test DB connection ────────────────────────────────────
echo "▶ Step 3: Testing database connection..."
PGPASSWORD=dallol2024 psql -h 127.0.0.1 -U postgres -d dallol_booking \
  -c "SELECT COUNT(*) AS hotels FROM hotels;" 2>&1

# ── Step 4: Start web server ─────────────────────────────────────
echo ""
echo "▶ Step 4: Starting web server..."
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅  Website is running!                                  ║"
echo "║                                                          ║"
echo "║  🌐  Guest Site:    http://localhost:8080                ║"
echo "║  🔐  Admin Panel:   http://localhost:8080/admin/login    ║"
echo "║                                                          ║"
echo "║  ADMIN CREDENTIALS:                                      ║"
echo "║  👑 Super Admin:  superadmin@dalloltech.com              ║"
echo "║                   Password: Admin@1234                   ║"
echo "║  🏙️  Sub Admin:   subadmin.addis@dalloltech.com          ║"
echo "║                   Password: SubAdmin@1234                ║"
echo "║  🤝 Broker:       broker1.addis@dalloltech.com           ║"
echo "║                   Password: Broker@1234                  ║"
echo "║  🏨 Manager:      manager.sheraton@dalloltech.com        ║"
echo "║                   Password: Manager@1234                 ║"
echo "║                                                          ║"
echo "║  Press Ctrl+C to stop the server                        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

php spark serve --host 0.0.0.0 --port 8080
