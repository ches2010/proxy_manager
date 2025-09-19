# app/modules/rotator.py
"""代理轮换器，负责管理、轮换和筛选代理。"""
from collections import defaultdict
import threading
import time

class ProxyRotator:
    """代理轮换器，负责管理、轮换和筛选代理。"""
    def __init__(self):
        self.all_proxies = []
        self.proxies_by_country = defaultdict(list)
        self.indices = defaultdict(lambda: -1)
        self.current_proxy = None
        self.lock = threading.Lock()
        
        # 保存当前激活的过滤器状态
        self.current_filter_region = "All"
        self.current_filter_quality_latency_ms = None
        
        # 代理统计信息
        self.stats = {
            'total': 0,
            'working': 0,
            'countries': defaultdict(int)
        }

    def clear(self):
        """清空所有代理，并重置内部状态。"""
        with self.lock:
            self.all_proxies = []
            self.proxies_by_country.clear()
            self.indices.clear()
            self.current_proxy = None
            self._update_stats()
    
    def _update_stats(self):
        """更新代理统计信息"""
        self.stats['total'] = len(self.all_proxies)
        self.stats['working'] = sum(1 for p in self.all_proxies if p.get('status') == 'Working')
        self.stats['countries'].clear()
        for p in self.all_proxies:
            if p.get('status') == 'Working':
                country = p.get('location', 'Unknown')
                self.stats['countries'][country] += 1

    def get_stats(self):
        """获取代理统计信息"""
        with self.lock:
            return {
                'total': self.stats['total'],
                'working': self.stats['working'],
                'countries': dict(self.stats['countries'])
            }

    # 其余方法保持不变...
