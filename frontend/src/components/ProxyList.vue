<template>
  <div class="proxy-list-container">
    <div class="filters">
      <el-select v-model="regionFilter" placeholder="Select region" @change="applyFilters">
        <el-option label="All" value="All"></el-option>
        <el-option v-for="region in regions" :key="region" :label="region" :value="region"></el-option>
      </el-select>
      
      <el-select v-model="latencyFilter" placeholder="Max latency (ms)" @change="applyFilters">
        <el-option label="Any" value=null></el-option>
        <el-option label="500ms" value=500></el-option>
        <el-option label="1000ms" value=1000></el-option>
        <el-option label="2000ms" value=2000></el-option>
      </el-select>
      
      <el-button type="primary" @click="fetchProxies">Fetch New Proxies</el-button>
      <el-button type="success" @click="checkProxies">Check All Proxies</el-button>
    </div>
    
    <el-table
      :data="filteredProxies"
      border
      style="width: 100%; margin-top: 16px;"
    >
      <el-table-column prop="proxy" label="Proxy" width="200"></el-table-column>
      <el-table-column prop="protocol" label="Protocol" width="100"></el-table-column>
      <el-table-column prop="location" label="Location" width="120"></el-table-column>
      <el-table-column prop="latency" label="Latency (ms)" width="120">
        <template #default="scope">{{ (scope.row.latency * 1000).toFixed(0) }}</template>
      </el-table-column>
      <el-table-column prop="status" label="Status" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.status === 'Working' ? 'success' : 'danger'">
            {{ scope.row.status }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="Actions" width="180">
        <template #default="scope">
          <el-button size="small" @click="setAsCurrent(scope.row.proxy)">Set Current</el-button>
          <el-button size="small" type="danger" @click="removeProxy(scope.row.proxy)">Remove</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <div class="pagination" v-if="total > 0">
      <el-pagination
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        :current-page="currentPage"
        :page-sizes="[10, 20, 50, 100]"
        :page-size="pageSize"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
      ></el-pagination>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { getProxies, fetchProxies, checkProxies, removeProxy, setCurrentProxy } from '../services/proxyService';

export default {
  name: 'ProxyList',
  setup() {
    const proxies = ref([]);
    const currentPage = ref(1);
    const pageSize = ref(20);
    const regionFilter = ref('All');
    const latencyFilter = ref(null);
    const regions = ref([]);
    
    const fetchProxyData = async () => {
      const data = await getProxies(regionFilter.value, latencyFilter.value);
      proxies.value = data;
      
      // Extract unique regions
      const uniqueRegions = [...new Set(data.map(p => p.location))];
      regions.value = uniqueRegions;
    };
    
    onMounted(fetchProxyData);
    
    const filteredProxies = computed(() => {
      const start = (currentPage.value - 1) * pageSize.value;
      const end = start + pageSize.value;
      return proxies.value.slice(start, end);
    });
    
    const total = computed(() => proxies.value.length);
    
    const applyFilters = async () => {
      currentPage.value = 1;
      await fetchProxyData();
    };
    
    const handleSizeChange = (size) => {
      pageSize.value = size;
      currentPage.value = 1;
    };
    
    const handleCurrentChange = (page) => {
      currentPage.value = page;
    };
    
    const fetchNewProxies = async () => {
      await fetchProxies();
      // Refresh list after a short delay to allow background task to complete
      setTimeout(fetchProxyData, 3000);
    };
    
    const checkAllProxies = async () => {
      await checkProxies();
    };
    
    const setAsCurrent = async (proxyAddress) => {
      await setCurrentProxy(proxyAddress);
    };
    
    const removeProxy = async (proxyAddress) => {
      await removeProxy(proxyAddress);
      fetchProxyData();
    };
    
    return {
      proxies,
      filteredProxies,
      currentPage,
      pageSize,
      total,
      regionFilter,
      latencyFilter,
      regions,
      applyFilters,
      handleSizeChange,
      handleCurrentChange,
      fetchProxies: fetchNewProxies,
      checkProxies: checkAllProxies,
      setAsCurrent,
      removeProxy
    };
  }
};
</script>

<style scoped>
.filters {
  display: flex;
  gap: 10px;
  margin-bottom: 16px;
  align-items: center;
}

.pagination {
  margin-top: 16px;
  text-align: right;
}
</style>
