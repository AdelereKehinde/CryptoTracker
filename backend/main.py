# --- User Profile Endpoint ---

# main.py
import httpx
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Depends, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from database import Base, engine, get_db
from models import User, SessionLog
from admin import router as admin_router
from jose import jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
import asyncio
from schemas import Holding, UserCreate, UserLogin, UserResponse
from typing import Any, Dict, Optional
import os
from dotenv import load_dotenv
from functools import lru_cache
import time

COINS_CACHE = {"data": None, "timestamp": 0}
CACHE_TTL = 3600  # 1 hour

load_dotenv()


COINGECKO_BASE = "https://api.coingecko.com/api/v3"
SECRET_KEY = "supersecretkey"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

app = FastAPI(title="Cheese_Ball Crypto Tracker API")

origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(admin_router)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

# --- User Auth ---
def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

from fastapi.responses import JSONResponse

@app.post("/signup")
def signup(user: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(
        (User.username == user.username) |
        (User.email == user.email) |
        (User.phone == user.phone)
    ).first():
        raise HTTPException(status_code=400, detail="User with username/email/phone already exists")

    new_user = User(
        username=user.username,
        email=user.email,
        phone=user.phone,
        country=user.country,
        hashed_password=get_password_hash(user.password)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"message": "Signup successful", "user": new_user.username}

@app.post("/token")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect username or password")
    token = create_access_token({"sub": db_user.username})
    return {"access_token": token, "token_type": "bearer"}

async def proxy_get(path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(f"{COINGECKO_BASE}{path}", params=params)
            response.raise_for_status()
            try:
                return response.json()
            except Exception:
                # Handle cases where response is text, not JSON
                return {"error": "Invalid response format", "raw": response.text}
    except httpx.RequestError:
        return {"error": "Network issue"}

@app.get("/coins/list")
async def coins_list():
    now = time.time()
    if COINS_CACHE["data"] and now - COINS_CACHE["timestamp"] < CACHE_TTL:
        return COINS_CACHE["data"]

    try:
        data = await proxy_get("/coins/list")
        COINS_CACHE["data"] = data
        COINS_CACHE["timestamp"] = now
        return data
    except:
        return {"error": "Failed to fetch coins list"}
    

@app.get("/simple/supported_vs_currencies")
async def supported_vs_currencies():
    return await proxy_get("/simple/supported_vs_currencies")

@app.get("/search/trending")
async def search_trending():
    return await proxy_get("/search/trending")

@app.get("/coins/categories/list")
async def categories_list():
    return await proxy_get("/coins/categories/list")

@app.get("/simple/price")
async def simple_price(vs_currencies: str, ids: str):
    return await proxy_get("/simple/price", params={"vs_currencies": vs_currencies, "ids": ids})

@app.get("/simple/token_price/{id}")
async def simple_token_price(id: str, contract_addresses: str, vs_currencies: str):
    return await proxy_get(f"/simple/token_price/{id}", params={"contract_addresses": contract_addresses, "vs_currencies": vs_currencies})

@app.get("/coins/markets")
async def coins_markets(vs_currency: str = "usd", ids: str = None):
    params = {"vs_currency": vs_currency}
    if ids:
        params["ids"] = ids
    return await proxy_get("/coins/markets", params=params)


@app.get("/coins/{id}")
async def coin_detail(id: str):
    return await proxy_get(f"/coins/{id}")

@app.get("/coins/{id}/tickers")
async def coin_tickers(id: str):
    return await proxy_get(f"/coins/{id}/tickers")

@app.get("/coins/{id}/market_chart")
async def coin_market_chart(id: str, vs_currency: str, days: str):
    return await proxy_get(f"/coins/{id}/market_chart", params={"vs_currency": vs_currency, "days": days})

from fastapi.security import OAuth2PasswordBearer
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")  # Make sure this is there

# Add this helper function (before @app.get("/profile"))
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    try:
        # Decode token to get username
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Replace the old /profile endpoint
@app.get("/profile", response_model=dict)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Get profile of CURRENTLY LOGGED IN user only"""
    return {
        "username": current_user.username,
        "email": current_user.email,
        "phone": current_user.phone or "Not set",
        "country": current_user.country or "Not set",
        "joined": current_user.created_at.strftime("%B %d, %Y") if current_user.created_at else "Unknown",
        "member_since": f"{current_user.created_at.strftime('%Y-%m-%d %H:%M')} UTC" if current_user.created_at else "Unknown"
    }


@app.get("/coins/{id}/market_chart/range")
async def coin_market_chart_range(id: str, vs_currency: str, from_: int, to: int):
    return await proxy_get(f"/coins/{id}/market_chart/range", params={"vs_currency": vs_currency, "from": from_, "to": to})

@app.get("/coins/{id}/ohlc")
async def coin_ohlc(id: str, vs_currency: str, days: str):
    return await proxy_get(f"/coins/{id}/ohlc", params={"vs_currency": vs_currency, "days": days})

@app.get("/coins/{platform_id}/contract/{contract_address}/market_chart")
async def contract_market_chart(platform_id: str, contract_address: str, vs_currency: str, days: str):
    return await proxy_get(f"/coins/{platform_id}/contract/{contract_address}/market_chart", params={"vs_currency": vs_currency, "days": days})

@app.get("/onchain/simple/token_price/{id}")
async def onchain_token_price(id: str, contract_addresses: str, vs_currencies: str):
    return await proxy_get(f"/onchain/simple/token_price/{id}", params={"contract_addresses": contract_addresses, "vs_currencies": vs_currencies})

@app.get("/global")
async def global_data():
    return await proxy_get("/global")

# --- WebSocket for Real-Time Updates ---

# --- Advanced WebSocket for Real-Time Market and Chart Updates ---
class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception:
                pass

manager = ConnectionManager()

@app.websocket("/ws/market")
async def websocket_market(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            await asyncio.sleep(5)
            trending = await proxy_get("/search/trending")
            global_data = await proxy_get("/global")
            await manager.broadcast({"type": "trending", "data": trending})
            await manager.broadcast({"type": "global", "data": global_data})
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# Real-time chart updates for a specific coin
@app.websocket("/ws/chart/{coin_id}")
async def websocket_chart(websocket: WebSocket, coin_id: str):
    await manager.connect(websocket)
    try:
        while True:
            await asyncio.sleep(10)
            # Send latest market chart (1d, 1h, 7d)
            chart_1d = await proxy_get(f"/coins/{coin_id}/market_chart", params={"vs_currency": "usd", "days": "1"})
            chart_7d = await proxy_get(f"/coins/{coin_id}/market_chart", params={"vs_currency": "usd", "days": "7"})
            await manager.broadcast({"type": "chart_1d", "coin": coin_id, "data": chart_1d})
            await manager.broadcast({"type": "chart_7d", "coin": coin_id, "data": chart_7d})
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# --- Advanced Analytics and Graph Endpoints ---
@app.get("/coins/{id}/price_change")
async def coin_price_change(id: str, vs_currency: str = "usd"):
    # Returns price change % for 1h, 24h, 7d, 30d, 1y
    data = await proxy_get(f"/coins/{id}", params={"localization": "false", "tickers": "false", "market_data": "true", "community_data": "false", "developer_data": "false", "sparkline": "false"})
    market = data.get("market_data", {})
    return {
        "price_change_percentage_1h": market.get("price_change_percentage_1h_in_currency", {}).get(vs_currency),
        "price_change_percentage_24h": market.get("price_change_percentage_24h_in_currency", {}).get(vs_currency),
        "price_change_percentage_7d": market.get("price_change_percentage_7d_in_currency", {}).get(vs_currency),
        "price_change_percentage_30d": market.get("price_change_percentage_30d_in_currency", {}).get(vs_currency),
        "price_change_percentage_1y": market.get("price_change_percentage_1y_in_currency", {}).get(vs_currency),
    }

@app.get("/coins/{id}/volume_dominance")
async def coin_volume_dominance(id: str, vs_currency: str = "usd"):
    data = await proxy_get(f"/coins/{id}", params={"localization": "false", "tickers": "false", "market_data": "true", "community_data": "false", "developer_data": "false", "sparkline": "false"})
    market = data.get("market_data", {})
    return {
        "total_volume": market.get("total_volume", {}).get(vs_currency),
        "market_cap": market.get("market_cap", {}).get(vs_currency),
        "market_cap_rank": data.get("market_cap_rank"),
        "dominance": market.get("market_cap", {}).get(vs_currency) / market.get("total_market_cap", {}).get(vs_currency, 1) if market.get("total_market_cap", {}).get(vs_currency) else None
    }

@app.get("/coins/{id}/ohlc_realtime")
async def coin_ohlc_realtime(id: str, vs_currency: str = "usd", days: str = "1"):
    # Returns OHLC data for advanced charting
    return await proxy_get(f"/coins/{id}/ohlc", params={"vs_currency": vs_currency, "days": days})

@app.get("/coins/{id}/market_chart/interval")
async def coin_market_chart_interval(id: str, vs_currency: str = "usd", interval: str = "hourly", days: str = "7"):
    # Returns market chart with custom interval
    return await proxy_get(f"/coins/{id}/market_chart", params={"vs_currency": vs_currency, "days": days, "interval": interval})

@app.get("/coins/{id}/analytics")
async def coin_analytics(id: str, vs_currency: str = "usd"):
    # Returns a bundle of analytics for a coin
    data = await proxy_get(f"/coins/{id}", params={"localization": "false", "tickers": "false", "market_data": "true", "community_data": "true", "developer_data": "true", "sparkline": "true"})
    return data

portfolio = []  # store holdings temporarily in memory

@app.post("/portfolio/add")
def add_holding(holding: Holding):
    portfolio.append(holding.dict())
    return {"message": "Holding added", "portfolio": portfolio}

@app.get("/portfolio")
def get_portfolio():
    return {"portfolio": portfolio}



from datetime import datetime 

@app.get("/watchlist")
async def get_watchlist():
    """
    Returns a small watchlist (proxied from CoinGecko top markets).
    Frontend expects: { "watchlist": [ {id, name, symbol, price, image}, ... ] }
    """
    try:
        markets = await proxy_get("/coins/markets", params={"vs_currency": "usd", "per_page": 6, "page": 1})
        watchlist = [
            {
                "id": c.get("id"),
                "name": c.get("name"),
                "symbol": c.get("symbol"),
                "price": c.get("current_price"),
                "image": c.get("image"),
            }
            for c in (markets or [])
        ]
    except Exception:
        watchlist = []
    return {"watchlist": watchlist}

@app.get("/notifications")
async def get_notifications():
    """
    Proxy CoinGecko status updates (or events) and return normalized notifications:
    { "notifications": [ {id, title, message, created_at, url}, ... ] }
    """
    notifications = []
    try:
        # Try CoinGecko status updates first
        data = await proxy_get("/status_updates", params={"per_page": 20, "page": 1})
        items = []
        if isinstance(data, dict):
            # coinGecko may return { "status_updates": [...] } or similar
            if "status_updates" in data and isinstance(data["status_updates"], list):
                items = data["status_updates"]
            elif "data" in data and isinstance(data["data"], list):
                items = data["data"]
        elif isinstance(data, list):
            items = data

        for it in items:
            notifications.append({
                "id": it.get("id") or it.get("status_update_id") or None,
                "title": it.get("title") or it.get("category") or "Update",
                "message": it.get("description") or it.get("body") or "",
                "created_at": it.get("created_at") or it.get("date") or None,
                "url": it.get("user_url") or it.get("link") or None
            })
    except Exception:
        # fallback to /events
        try:
            data = await proxy_get("/events", params={"page": 1, "per_page": 20})
            items = data.get("data") if isinstance(data, dict) and "data" in data else (data if isinstance(data, list) else [])
            for it in items:
                notifications.append({
                    "id": it.get("id") or None,
                    "title": it.get("title") or it.get("type") or "Event",
                    "message": it.get("description") or it.get("details") or "",
                    "created_at": it.get("start_date") or it.get("date") or None,
                    "url": it.get("website") or None
                })
        except Exception:
            # final fallback: return a small static notice
            now = datetime.utcnow().isoformat()
            notifications = [
                {"id": "local-1", "title": "No live notifications", "message": "Unable to fetch remote updates; showing demo notices.", "created_at": now, "url": None}
            ]

    return {"notifications": notifications}

@app.get("/news")
async def get_news():
    """
    News endpoint used by frontend. Returns list of news items.
    Fields: title, description, image_url, pubDate, source_id, link
    """
    # Try to return simple demo news. You can integrate real news API later.
    now = datetime.utcnow().isoformat()
    sample = [
        {
            "title": "Bitcoin rallies as markets rebound",
            "description": "Bitcoin saw gains as traders reacted to macro news.",
            "image_url": None,
            "pubDate": now,
            "source_id": "demo",
            "link": "https://coindesk.com"
        },
        {
            "title": "Altcoins show strength",
            "description": "Several altcoins outperformed in the last 24 hours.",
            "image_url": None,
            "pubDate": now,
            "source_id": "demo",
            "link": "https://decrypt.co"
        }
    ]
    return {"news": sample}

@app.get("/community")
async def get_community():
    """
    Community posts (demo). Frontend expects { "posts": [ {title, content}, ... ] }
    """
    posts = [
        {"id": 1, "title": "Welcome to Cheese_Ball Community", "content": "Share your insights and strategies here."},
        {"id": 2, "title": "Best wallets in 2025", "content": "What wallets are you using?"},
    ]
    return {"posts": posts}

@app.get("/analytics")
async def get_analytics():
    """
    Returns dashboard summary for frontend:
    { market_cap, volume_24h, btc_dominance, top_gainer, top_loser, active_coins, exchanges, pairs, markets_up }
    """
    try:
        global_data = await proxy_get("/global")
        gd = global_data.get("data", {}) if isinstance(global_data, dict) else {}
        market_cap = gd.get("total_market_cap", {}).get("usd")
        volume_24h = gd.get("total_volume", {}).get("usd")
        btc_dom = gd.get("market_cap_percentage", {}).get("btc")
    except Exception:
        market_cap = None
        volume_24h = None
        btc_dom = None

    # fetch top markets to compute top gainer/loser and counts
    try:
        markets = await proxy_get("/coins/markets", params={"vs_currency": "usd", "order": "market_cap_desc", "per_page": 100, "page": 1})
        markets_list = markets if isinstance(markets, list) else []
        active_coins = len(markets_list)
        markets_up = sum(1 for m in markets_list if (m.get("price_change_percentage_24h") or 0) > 0)
        sorted_by_change = sorted(markets_list, key=lambda m: (m.get("price_change_percentage_24h") or 0))
        top_loser = sorted_by_change[0].get("name") if sorted_by_change else None
        top_gainer = sorted_by_change[-1].get("name") if sorted_by_change else None
    except Exception:
        active_coins = 0
        markets_up = 0
        top_gainer = None
        top_loser = None

    analytics = {
        "market_cap": market_cap,
        "volume_24h": volume_24h,
        "btc_dominance": btc_dom,
        "top_gainer": top_gainer,
        "top_loser": top_loser,
        "active_coins": active_coins,
        "exchanges": 0,
        "pairs": 0,
        "markets_up": markets_up,
    }
    return analytics



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="127.0.0.1",
        port=8000,
        reload=True
    )
