#!/bin/bash
# Full Startup Script - All checks and startup

set -e

echo "🚀 ArchRampart Audit Tool - Full Startup"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Clean old processes
echo "1️⃣  Cleaning old processes..."
lsof -ti:8000 | xargs kill -9 2>/dev/null || true
lsof -ti:5173 | xargs kill -9 2>/dev/null || true
sleep 1
echo -e "${GREEN}   ✅ Cleaned${NC}"

# 2. PostgreSQL check
echo ""
echo "2️⃣  Checking PostgreSQL..."
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo -e "${YELLOW}   PostgreSQL is not running, starting...${NC}"
    sudo systemctl start postgresql 2>/dev/null || {
        echo -e "${RED}   ❌ PostgreSQL could not be started!${NC}"
        echo "   Please start manually: sudo systemctl start postgresql"
        exit 1
    }
    sleep 2
fi
echo -e "${GREEN}   ✅ PostgreSQL is running${NC}"

# 3. Database check
echo ""
echo "3️⃣  Checking database..."
if ! PGPASSWORD=archrampart_pass psql -h localhost -U archrampart -d archrampart_audit -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${YELLOW}   Creating database...${NC}"
    sudo -u postgres psql << SQL
CREATE DATABASE archrampart_audit;
CREATE USER archrampart WITH PASSWORD 'archrampart_pass';
GRANT ALL PRIVILEGES ON DATABASE archrampart_audit TO archrampart;
ALTER DATABASE archrampart_audit OWNER TO archrampart;
\q
SQL
fi
echo -e "${GREEN}   ✅ Database ready${NC}"

# 4. Node.js check
echo ""
echo "4️⃣  Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}   Installing Node.js...${NC}"
    if command -v snap &> /dev/null; then
        sudo snap install node --classic
    else
        echo -e "${RED}   ❌ Node.js could not be installed!${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}   ✅ Node.js: $(node --version)${NC}"

# 5. Backend dependencies
echo ""
echo "5️⃣  Checking backend dependencies..."
cd backend
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -q -r requirements.txt
cd ..
echo -e "${GREEN}   ✅ Backend ready${NC}"

# 6. Frontend dependencies
echo ""
echo "6️⃣  Checking frontend dependencies..."
cd frontend
if [ ! -d "node_modules" ]; then
    npm install
fi
cd ..
echo -e "${GREEN}   ✅ Frontend ready${NC}"

# 7. Start backend
echo ""
echo "7️⃣  Starting backend..."
cd backend
source venv/bin/activate
nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 > ../backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../.backend.pid
cd ..
sleep 5

# Backend check
if ps -p $BACKEND_PID > /dev/null; then
    # API test
    sleep 2
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Backend is running (PID: $BACKEND_PID)${NC}"
    else
        echo -e "${YELLOW}   ⚠️  Backend started but not ready yet${NC}"
        echo "   Check logs: tail -f backend.log"
    fi
else
    echo -e "${RED}   ❌ Backend could not be started!${NC}"
    echo "   Logs:"
    tail -20 backend.log
    exit 1
fi

# 8. Start frontend
echo ""
echo "8️⃣  Starting frontend..."
cd frontend
nohup npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../.frontend.pid
cd ..
sleep 8

# Frontend check
if ps -p $FRONTEND_PID > /dev/null; then
    echo -e "${GREEN}   ✅ Frontend started (PID: $FRONTEND_PID)${NC}"
else
    echo -e "${RED}   ❌ Frontend could not be started!${NC}"
    echo "   Logs:"
    tail -20 frontend.log
    exit 1
fi

# 9. Result
IP=$(hostname -I | awk '{print $1}')
echo ""
echo "=========================================="
echo -e "${GREEN}✅ APPLICATION STARTED SUCCESSFULLY!${NC}"
echo "=========================================="
echo ""
echo "📍 Server IP: $IP"
echo ""
echo "🌐 Access Addresses:"
echo "   Frontend:  http://$IP:5173"
echo "   Backend:   http://$IP:8000"
echo "   API Docs:  http://$IP:8000/docs"
echo ""
echo "📋 Logs:"
echo "   Backend:  tail -f backend.log"
echo "   Frontend: tail -f frontend.log"
echo ""
echo "🛑 To stop:"
echo "   ./stop.sh"
echo ""
