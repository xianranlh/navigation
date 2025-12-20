<template>
  <header class="app-header glass-panel">
    <div class="header-content">
      <!-- Logo 区域 -->
      <div class="header-logo" @click="goHome">
        <span class="logo-icon">🚀</span>
        <span class="logo-text">星穹导航</span>
      </div>

      <!-- 搜索栏 -->
      <SearchBar 
        ref="searchBarRef"
        @select="handleSearchSelect"
        class="header-search"
      />

      <!-- 右侧操作区 -->
      <div class="header-actions">
        <!-- 快速添加按钮 -->
        <button 
          class="action-btn add-btn glass-button glass-button-primary"
          @click="showQuickAdd = true"
        >
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
          </svg>
          <span class="btn-text">添加</span>
        </button>

        <!-- 主题切换 -->
        <button 
          class="action-btn icon-btn"
          @click="toggleTheme"
          :title="isDark ? '切换亮色' : '切换暗色'"
        >
          <svg v-if="isDark" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zM2 13h2c.55 0 1-.45 1-1s-.45-1-1-1H2c-.55 0-1 .45-1 1s.45 1 1 1zm18 0h2c.55 0 1-.45 1-1s-.45-1-1-1h-2c-.55 0-1 .45-1 1s.45 1 1 1zM11 2v2c0 .55.45 1 1 1s1-.45 1-1V2c0-.55-.45-1-1-1s-1 .45-1 1zm0 18v2c0 .55.45 1 1 1s1-.45 1-1v-2c0-.55-.45-1-1-1s-1 .45-1 1zM5.99 4.58c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0s.39-1.03 0-1.41L5.99 4.58zm12.37 12.37c-.39-.39-1.03-.39-1.41 0-.39.39-.39 1.03 0 1.41l1.06 1.06c.39.39 1.03.39 1.41 0 .39-.39.39-1.03 0-1.41l-1.06-1.06zm1.06-10.96c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06zM7.05 18.36c.39-.39.39-1.03 0-1.41-.39-.39-1.03-.39-1.41 0l-1.06 1.06c-.39.39-.39 1.03 0 1.41s1.03.39 1.41 0l1.06-1.06z"/>
          </svg>
          <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M9.37 5.51c-.18.64-.27 1.31-.27 1.99 0 4.08 3.32 7.4 7.4 7.4.68 0 1.35-.09 1.99-.27C17.45 17.19 14.93 19 12 19c-3.86 0-7-3.14-7-7 0-2.93 1.81-5.45 4.37-6.49zM12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"/>
          </svg>
        </button>

        <!-- 设置 -->
        <button 
          class="action-btn icon-btn"
          @click="goSettings"
          title="设置"
        >
          <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M19.14 12.94c.04-.31.06-.63.06-.94 0-.31-.02-.63-.06-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.04.31-.06.63-.06.94s.02.63.06.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- 快速添加弹窗 -->
    <QuickAddModal 
      v-model:visible="showQuickAdd"
      @success="handleAddSuccess"
    />
  </header>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useSettingsStore } from '../../stores/settings'
import { useLinkStore } from '../../stores/link'
import SearchBar from '../features/SearchBar.vue'
import QuickAddModal from '../features/QuickAddModal.vue'

const router = useRouter()
const settingsStore = useSettingsStore()
const linkStore = useLinkStore()

const searchBarRef = ref(null)
const showQuickAdd = ref(false)

const isDark = computed(() => settingsStore.theme === 'dark')

function goHome() {
  router.push('/')
}

function goSettings() {
  router.push('/settings')
}

function toggleTheme() {
  settingsStore.setTheme(isDark.value ? 'light' : 'dark')
}

function handleSearchSelect(link) {
  // 打开链接
  linkStore.recordClick(link.id)
  window.open(link.url, '_blank')
}

function handleAddSuccess() {
  // 刷新分类数据等
}

// 快捷键 Ctrl+K 打开搜索
document.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault()
    searchBarRef.value?.focus()
  }
  // Ctrl+D 打开快速添加
  if ((e.ctrlKey || e.metaKey) && e.key === 'd') {
    e.preventDefault()
    showQuickAdd.value = true
  }
})
</script>

<style scoped>
.app-header {
  position: sticky;
  top: 0;
  z-index: 100;
  margin-bottom: 24px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 12px 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.header-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  flex-shrink: 0;
}

.logo-icon {
  font-size: 24px;
}

.logo-text {
  font-size: 20px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--hsr-gold), var(--hsr-cyan));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-search {
  flex: 1;
  max-width: 500px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.add-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
}

.btn-text {
  font-size: 14px;
}

.icon-btn {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--hsr-radius-md);
  color: var(--hsr-text-secondary);
  transition: all 0.2s ease;
}

.icon-btn:hover {
  color: var(--hsr-cyan);
  background: rgba(0, 212, 255, 0.1);
}

/* 响应式 */
@media (max-width: 768px) {
  .header-content {
    gap: 12px;
    padding: 10px 16px;
  }

  .logo-text {
    display: none;
  }

  .btn-text {
    display: none;
  }

  .add-btn {
    width: 40px;
    height: 40px;
    padding: 0;
    justify-content: center;
  }
}
</style>
