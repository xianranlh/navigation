<template>
  <div class="app-wrapper">
    <!-- 星空背景 -->
    <div class="starfield-bg"></div>
    
    <!-- 主内容 -->
    <div class="app-container">
      <AppHeader />
      
      <main class="main-content">
        <router-view v-slot="{ Component }">
          <Transition name="page" mode="out-in">
            <component :is="Component" />
          </Transition>
        </router-view>
      </main>
    </div>

    <!-- Toast 通知 -->
    <ToastContainer />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useSettingsStore } from './stores/settings'
import AppHeader from './components/layout/AppHeader.vue'
import ToastContainer from './components/common/ToastContainer.vue'

const settingsStore = useSettingsStore()

onMounted(() => {
  settingsStore.initTheme()
})
</script>

<style>
@import './assets/styles/variables.css';
@import './assets/styles/animations.css';
@import './assets/styles/glassmorphism.css';

/* 字体 */
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap');
</style>

<style scoped>
.app-wrapper {
  min-height: 100vh;
  position: relative;
}

.app-container {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 0 24px 40px;
}

/* 页面过渡动画 */
.page-enter-active,
.page-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* 响应式 */
@media (max-width: 768px) {
  .main-content {
    padding: 0 16px 24px;
  }
}
</style>
