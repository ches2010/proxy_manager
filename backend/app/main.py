from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.api import router as api_router
from app.core.rotator import ProxyRotator
from app.core.fetcher import ProxyFetcher
from app.core.checker import ProxyChecker
from app.core.server import ProxyServer
from app.config import settings

app = FastAPI(
    title="Proxy Manager API",
    description="A powerful proxy management tool",
    version="1.0.0"
)

# 跨域设置
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化核心组件
rotator = ProxyRotator()
fetcher = ProxyFetcher()
checker = ProxyChecker(rotator)
proxy_server = ProxyServer(
    http_host=settings.HTTP_HOST,
    http_port=settings.HTTP_PORT,
    socks5_host=settings.SOCKS5_HOST,
    socks5_port=settings.SOCKS5_PORT,
    rotator=rotator,
    log_queue=None  # 后续可集成日志队列
)

# 依赖项
def get_rotator():
    return rotator

def get_fetcher():
    return fetcher

def get_checker():
    return checker

def get_proxy_server():
    return proxy_server

# 注册路由
app.include_router(api_router)

@app.get("/")
async def root():
    return {"message": "Welcome to Proxy Manager API"}
