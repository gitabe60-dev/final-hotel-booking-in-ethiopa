#!/bin/bash
# ═══════════════════════════════════════════════════════
#  DALLOL BOOKING + ERP — ONE CLICK START
#  Run:  bash START.sh
# ═══════════════════════════════════════════════════════
set -e
BASE="$(dirname "$0")"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   DALLOL TECH SYSTEMS — STARTING UP         ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── 1. Make sure PostgreSQL is running ────────────────
echo "→ Starting PostgreSQL..."
sudo service postgresql start 2>/dev/null || true
sleep 1

# ── 2. Set postgres password ──────────────────────────
echo "→ Setting database passwords..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '1212';" 2>/dev/null || true
sudo -u postgres psql -c "ALTER USER dallol_app WITH PASSWORD '1212';" 2>/dev/null || true

# ── 3. Verify connections ─────────────────────────────
echo "→ Checking databases..."
BOOKING=$(PGPASSWORD=1212 psql -h 127.0.0.1 -U dallol_app -d dallol_booking \
  -t -c "SELECT COUNT(*) FROM hotels;" 2>/dev/null | tr -d ' ')
ERP=$(PGPASSWORD=1212 psql -h 127.0.0.1 -U postgres -d dallol \
  -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')

echo "  ✅  Booking DB: $BOOKING hotels"
echo "  ✅  ERP DB: $ERP users"

# ── 4. Run ERP migrations ─────────────────────────────
echo "→ Running ERP migrations..."
cd "$BASE/erp" && php spark migrate 2>/dev/null | tail -1
cd "$BASE"

# ── 5. Start Booking Website (port 8080) ─────────────
echo "→ Starting Booking Website on port 8080..."
cd "$BASE/booking_website"
php spark serve --host 0.0.0.0 --port 8080 > /tmp/booking_server.log 2>&1 &
BOOKING_PID=$!
cd "$BASE"

# ── 6. Start ERP (port 8081) ─────────────────────────
echo "→ Starting ERP System on port 8081..."
cd "$BASE/erp"
php spark serve --host 0.0.0.0 --port 8081 > /tmp/erp_server.log 2>&1 &
ERP_PID=$!
cd "$BASE"

sleep 3

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   ✅  ALL SYSTEMS RUNNING!                                    ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║                                                              ║"
echo "║  BOOKING WEBSITE  →  http://localhost:8080                   ║"
echo "║  ERP SYSTEM       →  http://localhost:8081                   ║"
echo "║                                                              ║"
echo "║  ── BOOKING LOGINS ───────────────────────────────────────── ║"
echo "║  Register free:   http://localhost:8080/register             ║"
echo "║  Admin panel:     http://localhost:8080/admin/login          ║"
echo "║  👑 Super Admin:  superadmin@dalloltech.com / Admin@1234     ║"
echo "║  🏙️  Sub Admin:   subadmin.addis@dalloltech.com / SubAdmin@1234║"
echo "║  🤝 Broker:       broker1.addis@dalloltech.com / Broker@1234 ║"
echo "║  🏨 Manager:      manager.sheraton@dalloltech.com / Manager@1234║"
echo "║                                                              ║"
echo "║  ── ERP LOGINS ───────────────────────────────────────────── ║"
echo "║  ERP Login:       http://localhost:8081/auth/login           ║"
echo "║  👑 Super Admin:  admin / admin123  (view-only)              ║"
echo "║  🏢 Company User: companyuser / Company@1234  (full access)  ║"
echo "║                                                              ║"
echo "║  ── DB CREDENTIALS ───────────────────────────────────────── ║"
echo "║  PostgreSQL password: 1212                                   ║"
echo "║  Booking DB:  dallol_booking  (user: dallol_app)            ║"
echo "║  ERP DB:      dallol          (user: postgres)               ║"
echo "║                                                              ║"
echo "║  Press Ctrl+C to stop all servers                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Keep running until Ctrl+C
trap "kill $BOOKING_PID $ERP_PID 2>/dev/null; echo ''; echo 'All servers stopped.'; exit 0" INT TERM
wait
