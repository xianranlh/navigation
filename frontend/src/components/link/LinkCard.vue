<template>
  <div 
    class="link-card glass-card hover-lift"
    :class="{ 'is-selected': isSelected, 'is-dragging': isDragging }"
    @click="handleClick"
    @contextmenu.prevent="showContextMenu"
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
  >
    <!-- 图标 -->
    <div class="link-icon">
      <img 
        v-if="link.icon && !iconError" 
        :src="link.icon" 
        :alt="link.title"
        @error="iconError = true"
      />
      <div v-else class="icon-placeholder">
        {{ link.title?.charAt(0)?.toUpperCase() || '?' }}
      </div>
    </div>

    <!-- 内容 -->
    <div class="link-content">
      <h4 class="link-title">{{ link.title }}</h4>
      <p v-if="showDescription && link.description" class="link-desc">
        {{ link.description }}
      </p>
      <span class="link-url">{{ displayUrl }}</span>
    </div>

    <!-- 悬浮操作按钮 -->
    <Transition name="fade">
      <div v-show="isHovered && !isDragging && isLoggedIn" class="link-actions">
        <button class="action-btn" @click.stop="handleEdit" title="编辑">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
            <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
        </button>
        <button class="action-btn action-delete" @click.stop="handleDelete" title="删除">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
            <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
          </svg>
        </button>
      </div>
    </Transition>

    <!-- 点击数标记 -->
    <div v-if="link.clickCount > 0" class="click-badge">
      {{ formatClickCount(link.clickCount) }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useSettingsStore } from '../../stores/settings'
import { useAuthStore } from '../../stores/auth'

const props = defineProps({
  link: {
    type: Object,
    required: true
  },
  isSelected: {
    type: Boolean,
    default: false
  },
  isDragging: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['click', 'edit', 'delete', 'contextmenu'])

const settingsStore = useSettingsStore()
const authStore = useAuthStore()
const isHovered = ref(false)
const iconError = ref(false)

const showDescription = computed(() => settingsStore.showDescription)
const isLoggedIn = computed(() => authStore.isLoggedIn)

const displayUrl = computed(() => {
  try {
    const url = new URL(props.link.url)
    return url.hostname.replace('www.', '')
  } catch {
    return props.link.url
  }
})

function formatClickCount(count) {
  if (count >= 1000) {
    return (count / 1000).toFixed(1) + 'k'
  }
  return count
}

function handleClick() {
  emit('click', props.link)
}

function handleEdit() {
  if (!isLoggedIn.value) return
  emit('edit', props.link)
}

function handleDelete() {
  if (!isLoggedIn.value) return
  emit('delete', props.link)
}

function showContextMenu(event) {
  if (!isLoggedIn.value) return
  emit('contextmenu', { event, link: props.link })
}
</script>

<style scoped>
.link-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
}

.link-card.is-selected {
  border-color: var(--hsr-cyan);
  background: rgba(0, 212, 255, 0.1);
}

.link-card.is-dragging {
  opacity: 0.6;
  transform: scale(1.02);
}

/* 图标 */
.link-icon {
  width: 40px;
  height: 40px;
  flex-shrink: 0;
  border-radius: var(--hsr-radius-md);
  overflow: hidden;
  background: rgba(139, 122, 173, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.link-icon img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.icon-placeholder {
  font-size: 18px;
  font-weight: 600;
  color: var(--hsr-gold);
  text-shadow: 0 0 10px var(--hsr-gold-glow);
}

/* 内容 */
.link-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.link-title {
  font-size: 14px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.link-desc {
  font-size: 12px;
  color: var(--hsr-text-secondary);
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.link-url {
  font-size: 11px;
  color: var(--hsr-text-muted);
}

/* 操作按钮 */
.link-actions {
  display: flex;
  gap: 4px;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
}

.action-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--hsr-radius-sm);
  background: rgba(45, 38, 64, 0.9);
  color: var(--hsr-text-secondary);
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: var(--hsr-cyan);
  color: var(--hsr-bg-deep);
}

.action-btn.action-delete:hover {
  background: #ff4757;
}

/* 点击数 */
.click-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  background: rgba(255, 215, 0, 0.2);
  color: var(--hsr-gold);
  opacity: 0.7;
}

/* 过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
