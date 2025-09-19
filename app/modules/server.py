# app/modules/server.py
import socket
import threading
import select
import struct
import socks 
from urllib.parse import urlparse
import logging

class ProxyServer:
    """本地代理服务，将进入的请求通过代理池转发。支持HTTP和SOCKS5。"""
    def __init__(self, http_host, http_port, socks5_host, socks5_port, rotator, log_queue):
        self._rotator = rotator
        self._log_queue = log_queue
        self._running = False

        self._http_host = http_host
        self._http_port = http_port
        self._http_server_socket = None
        self._http_thread = None

        self._socks5_host = socks5_host
        self._socks5_port = socks5_port
        self._socks5_server_socket = None
        self._socks5_thread = None
        
        # 轮换模式状态
        self.rotate_per_request = False
        
        # 添加日志配置
        self.logger = logging.getLogger('ProxyServer')

    def log(self, message):
        self._log_queue.put(f"[{datetime.now().strftime('%H:%M:%S')}] [Server] {message}")

    def set_rotation_mode(self, per_request: bool):
        """设置代理轮换模式。"""
        self.rotate_per_request = per_request
        mode = "逐请求轮换" if per_request else "固定当前"
        self.log(f"服务轮换模式已切换为: {mode}")

    def start_all(self):
        """启动所有代理服务（HTTP & SOCKS5）。"""
        if self._running:
            return
        self._running = True

        self._http_thread = threading.Thread(target=self._run_http_server, daemon=True)
        self._http_thread.start()

        self._socks5_thread = threading.Thread(target=self._run_socks5_server, daemon=True)
        self._socks5_thread.start()

    def stop_all(self):
        """平滑地停止所有正在运行的代理服务。"""
        if not self._running:
            return
        self._running = False
        
        # 关闭服务器 socket
        if self._http_server_socket:
            try:
                self._http_server_socket.shutdown(socket.SHUT_RDWR)
                self._http_server_socket.close()
            except Exception as e:
                self.log(f"关闭HTTP服务器时出错: {e}")
        
        if self._socks5_server_socket:
            try:
                self._socks5_server_socket.shutdown(socket.SHUT_RDWR)
                self._socks5_server_socket.close()
            except Exception as e:
                self.log(f"关闭SOCKS5服务器时出错: {e}")

        # 等待线程结束
        if self._http_thread and self._http_thread.is_alive():
            self._http_thread.join(timeout=5)
        if self._socks5_thread and self._socks5_thread.is_alive():
            self._socks5_thread.join(timeout=5)
            
        self.log("所有代理服务已停止。")

    # 其余方法保持不变...
