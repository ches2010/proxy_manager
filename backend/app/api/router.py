from fastapi import APIRouter, Depends, BackgroundTasks
from app.core.rotator import ProxyRotator
from app.core.fetcher import ProxyFetcher
from app.core.checker import ProxyChecker
from app.core.server import ProxyServer
from app.schemas.proxy import ProxyInfo, ProxyFilter

router = APIRouter()

@router.get("/proxies", response_model=list[ProxyInfo])
def get_proxies(
    rotator: ProxyRotator = Depends(get_rotator),
    filter: ProxyFilter = Depends()
):
    """获取所有代理"""
    rotator.set_filters(region=filter.region, quality_latency_ms=filter.latency)
    return rotator.all_proxies

@router.post("/proxies/fetch")
def fetch_proxies(
    background_tasks: BackgroundTasks,
    fetcher: ProxyFetcher = Depends(get_fetcher),
    rotator: ProxyRotator = Depends(get_rotator)
):
    """获取新代理（后台任务）"""
    background_tasks.add_task(fetcher.fetch_and_save_proxies, rotator)
    return {"message": "Proxy fetching started in background"}

@router.post("/proxies/check")
def check_proxies(
    background_tasks: BackgroundTasks,
    checker: ProxyChecker = Depends(get_checker)
):
    """验证所有代理（后台任务）"""
    background_tasks.add_task(checker.check_all_proxies)
    return {"message": "Proxy checking started in background"}

@router.post("/server/start")
def start_server(server: ProxyServer = Depends(get_proxy_server)):
    """启动代理服务"""
    server.start_all()
    return {"message": "Proxy server started"}

@router.post("/server/stop")
def stop_server(server: ProxyServer = Depends(get_proxy_server)):
    """停止代理服务"""
    server.stop_all()
    return {"message": "Proxy server stopped"}

@router.post("/server/rotate-mode")
def set_rotation_mode(
    per_request: bool,
    server: ProxyServer = Depends(get_proxy_server)
):
    """设置代理轮换模式"""
    server.set_rotation_mode(per_request)
    return {"message": f"Rotation mode set to {'per request' if per_request else 'fixed'}"}
