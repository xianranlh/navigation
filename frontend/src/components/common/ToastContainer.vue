<template>
  <div class="toast-container">
    <TransitionGroup name="toast">
      <div 
        v-for="toast in toasts" 
        :key="toast.id"
        class="toast-item"
        :class="[`toast-${toast.type}`, { 'is-hiding': !toast.visible }]"
      >
        <!-- 图标 -->
        <div class="toast-icon">
          <svg v-if="toast.type === 'success'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
          </svg>
          <svg v-else-if="toast.type === 'error'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
          </svg>
          <svg v-else-if="toast.type === 'warning'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>
          </svg>
          <svg v-else-if="toast.type === 'undo'" viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M12.5 8c-2.65 0-5.05.99-6.9 2.6L2 7v9h9l-3.62-3.62c1.39-1.16 3.16-1.88 5.12-1.88 3.54 0 6.55 2.31 7.6 5.5l2.37-.78C21.08 11.03 17.15 8 12.5 8z"/>
          </svg>
          <svg v-else viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>
          </svg>
        </div>

        <!-- 内容 -->
        <div class="toast-content">
          {{ toast.message }}
        </div>

        <!-- 撤销按钮 -->
        <button 
          v-if="toast.type === 'undo' && toast.onUndo"
          class="undo-btn"
          @click="toast.onUndo"
        >
          撤销
        </button>

        <!-- 关闭按钮 -->
        <button class="close-btn" @click="removeToast(toast.id)">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
          </svg>
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useToastStore } from '../../stores/toast'

const toastStore = useToastStore()

const toasts = computed(() => toastStore.toasts)

function removeToast(id) {
  toastStore.remove(id)
}
</script>

<style scoped>
.toast-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-width: 400px;
}

.toast-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(45, 38, 64, 0.95);
  backdrop-filter: blur(20px);
  border-radius: var(--hsr-radius-md);
  border: 1px solid var(--hsr-border);
  box-shadow: var(--hsr-shadow-lg);
}

.toast-success {
  border-color: rgba(46, 213, 115, 0.4);
}

.toast-success .toast-icon {
  color: #2ed573;
}

.toast-error {
  border-color: rgba(255, 71, 87, 0.4);
}

.toast-error .toast-icon {
  color: #ff4757;
}

.toast-warning {
  border-color: rgba(255, 165, 0, 0.4);
}

.toast-warning .toast-icon {
  color: #ffa500;
}

.toast-info {
  border-color: var(--hsr-border-hover);
}

.toast-info .toast-icon {
  color: var(--hsr-cyan);
}

.toast-undo {
  border-color: var(--hsr-border-gold);
}

.toast-undo .toast-icon {
  color: var(--hsr-gold);
}

.toast-icon {
  flex-shrink: 0;
}

.toast-content {
  flex: 1;
  font-size: 14px;
  color: var(--hsr-text-primary);
}

.undo-btn {
  padding: 4px 12px;
  border-radius: var(--hsr-radius-sm);
  background: rgba(255, 215, 0, 0.2);
  color: var(--hsr-gold);
  font-size: 12px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.undo-btn:hover {
  background: rgba(255, 215, 0, 0.3);
}

.close-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  color: var(--hsr-text-muted);
  border-radius: 4px;
  transition: all 0.2s ease;
}

.close-btn:hover {
  color: var(--hsr-text-primary);
  background: rgba(255, 255, 255, 0.1);
}

/* 动画 */
.toast-enter-active {
  animation: slideInRight 0.3s ease;
}

.toast-leave-active {
  animation: slideOutRight 0.3s ease;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideOutRight {
  from {
    opacity: 1;
    transform: translateX(0);
  }
  to {
    opacity: 0;
    transform: translateX(100px);
  }
}
</style>
