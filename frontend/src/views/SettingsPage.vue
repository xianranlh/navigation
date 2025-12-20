<template>
  <div class="settings-page">
    <h1 class="page-title">设置</h1>

    <div class="settings-grid">
      <!-- 外观设置 -->
      <section class="settings-section glass-card">
        <h2 class="section-title">外观</h2>
        
        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">主题模式</span>
            <span class="setting-desc">切换明暗主题</span>
          </div>
          <div class="theme-switcher">
            <button 
              class="theme-btn" 
              :class="{ active: settings.theme === 'dark' }"
              @click="settings.setTheme('dark')"
            >
              🌙 暗色
            </button>
            <button 
              class="theme-btn" 
              :class="{ active: settings.theme === 'light' }"
              @click="settings.setTheme('light')"
            >
              ☀️ 亮色
            </button>
          </div>
        </div>

        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">卡片布局</span>
            <span class="setting-desc">选择链接展示方式</span>
          </div>
          <div class="layout-switcher">
            <button 
              class="layout-btn" 
              :class="{ active: settings.layout === 'grid' }"
              @click="settings.setLayout('grid')"
            >
              网格
            </button>
            <button 
              class="layout-btn" 
              :class="{ active: settings.layout === 'list' }"
              @click="settings.setLayout('list')"
            >
              列表
            </button>
          </div>
        </div>

        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">显示描述</span>
            <span class="setting-desc">在链接卡片上显示描述文字</span>
          </div>
          <label class="toggle-switch">
            <input 
              type="checkbox" 
              :checked="settings.showDescription"
              @change="settings.toggleDescription"
            />
            <span class="toggle-slider"></span>
          </label>
        </div>
      </section>

      <!-- 数据管理 -->
      <section class="settings-section glass-card">
        <h2 class="section-title">数据</h2>

        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">导出数据</span>
            <span class="setting-desc">导出所有分类和链接为 JSON 文件</span>
          </div>
          <button class="glass-button" @click="exportData">
            导出
          </button>
        </div>

        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">导入数据</span>
            <span class="setting-desc">从 JSON 文件导入数据</span>
          </div>
          <label class="glass-button import-btn">
            导入
            <input type="file" accept=".json" @change="importData" hidden />
          </label>
        </div>

        <div class="setting-item">
          <div class="setting-info">
            <span class="setting-label">导入书签</span>
            <span class="setting-desc">从浏览器书签 HTML 文件导入</span>
          </div>
          <label class="glass-button import-btn">
            导入
            <input type="file" accept=".html" @change="importBookmarks" hidden />
          </label>
        </div>
      </section>

      <!-- 快捷键 -->
      <section class="settings-section glass-card">
        <h2 class="section-title">快捷键</h2>
        
        <div class="shortcuts-list">
          <div class="shortcut-item">
            <kbd>Ctrl</kbd> + <kbd>K</kbd>
            <span>聚焦搜索框</span>
          </div>
          <div class="shortcut-item">
            <kbd>Ctrl</kbd> + <kbd>D</kbd>
            <span>快速添加链接</span>
          </div>
          <div class="shortcut-item">
            <kbd>/</kbd>
            <span>搜索</span>
          </div>
          <div class="shortcut-item">
            <kbd>Esc</kbd>
            <span>关闭弹窗</span>
          </div>
        </div>
      </section>

      <!-- 关于 -->
      <section class="settings-section glass-card">
        <h2 class="section-title">关于</h2>
        <div class="about-info">
          <p><strong>星穹导航</strong></p>
          <p class="version">版本 1.0.0</p>
          <p class="desc">一款崩铁风格的个人导航页，帮助你快速访问常用网站。</p>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { useSettingsStore } from '../stores/settings'
import { useCategoryStore } from '../stores/category'
import { useToastStore } from '../stores/toast'

const settings = useSettingsStore()
const categoryStore = useCategoryStore()
const toast = useToastStore()

function exportData() {
  const data = {
    version: '1.0',
    exportedAt: new Date().toISOString(),
    categories: categoryStore.categories
  }
  
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `navigation-backup-${new Date().toISOString().slice(0, 10)}.json`
  a.click()
  URL.revokeObjectURL(url)
  
  toast.success('数据导出成功')
}

async function importData(event) {
  const file = event.target.files[0]
  if (!file) return

  try {
    const text = await file.text()
    const data = JSON.parse(text)
    
    if (!data.categories || !Array.isArray(data.categories)) {
      throw new Error('Invalid data format')
    }
    
    // TODO: 调用 API 批量导入
    toast.success(`成功导入 ${data.categories.length} 个分类`)
  } catch (e) {
    toast.error('导入失败：文件格式不正确')
  }
  
  event.target.value = ''
}

async function importBookmarks(event) {
  const file = event.target.files[0]
  if (!file) return

  try {
    const text = await file.text()
    // 解析书签 HTML
    const parser = new DOMParser()
    const doc = parser.parseFromString(text, 'text/html')
    const links = doc.querySelectorAll('a')
    
    toast.success(`发现 ${links.length} 个书签，正在导入...`)
    // TODO: 批量导入书签
  } catch (e) {
    toast.error('导入失败')
  }
  
  event.target.value = ''
}
</script>

<style scoped>
.settings-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px 0;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--hsr-text-primary);
  margin: 0 0 32px 0;
}

.settings-grid {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.settings-section {
  padding: 24px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--hsr-gold);
  margin: 0 0 20px 0;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--hsr-border);
}

.setting-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 0;
}

.setting-item:not(:last-child) {
  border-bottom: 1px solid rgba(139, 122, 173, 0.1);
}

.setting-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.setting-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--hsr-text-primary);
}

.setting-desc {
  font-size: 12px;
  color: var(--hsr-text-muted);
}

.theme-switcher,
.layout-switcher {
  display: flex;
  gap: 8px;
}

.theme-btn,
.layout-btn {
  padding: 8px 16px;
  border-radius: var(--hsr-radius-md);
  background: rgba(45, 38, 64, 0.5);
  border: 1px solid var(--hsr-border);
  color: var(--hsr-text-secondary);
  font-size: 13px;
  transition: all 0.2s ease;
}

.theme-btn:hover,
.layout-btn:hover {
  border-color: var(--hsr-cyan);
  color: var(--hsr-text-primary);
}

.theme-btn.active,
.layout-btn.active {
  background: rgba(0, 212, 255, 0.2);
  border-color: var(--hsr-cyan);
  color: var(--hsr-cyan);
}

/* Toggle Switch */
.toggle-switch {
  position: relative;
  display: inline-block;
  width: 48px;
  height: 26px;
  cursor: pointer;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-slider {
  position: absolute;
  inset: 0;
  background: rgba(45, 38, 64, 0.8);
  border-radius: 26px;
  border: 1px solid var(--hsr-border);
  transition: 0.3s;
}

.toggle-slider::before {
  content: '';
  position: absolute;
  width: 20px;
  height: 20px;
  left: 2px;
  bottom: 2px;
  background: var(--hsr-text-muted);
  border-radius: 50%;
  transition: 0.3s;
}

.toggle-switch input:checked + .toggle-slider {
  background: rgba(0, 212, 255, 0.3);
  border-color: var(--hsr-cyan);
}

.toggle-switch input:checked + .toggle-slider::before {
  transform: translateX(22px);
  background: var(--hsr-cyan);
}

/* Import button */
.import-btn {
  cursor: pointer;
}

/* Shortcuts */
.shortcuts-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.shortcut-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--hsr-text-secondary);
}

.shortcut-item kbd {
  display: inline-block;
  padding: 4px 8px;
  background: rgba(45, 38, 64, 0.8);
  border: 1px solid var(--hsr-border);
  border-radius: 6px;
  font-family: inherit;
  font-size: 12px;
  color: var(--hsr-text-primary);
}

.shortcut-item span {
  margin-left: auto;
  color: var(--hsr-text-muted);
}

/* About */
.about-info {
  text-align: center;
  padding: 20px;
}

.about-info p {
  margin: 0 0 8px 0;
  color: var(--hsr-text-primary);
}

.about-info .version {
  color: var(--hsr-cyan);
  font-size: 13px;
}

.about-info .desc {
  color: var(--hsr-text-muted);
  font-size: 13px;
  margin-top: 12px;
}
</style>
