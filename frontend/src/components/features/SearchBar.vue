<template>
  <div class="search-bar-wrapper">
    <div class="search-bar glass-card" :class="{ 'is-focused': isFocused }">
      <!-- 搜索图标 -->
      <div class="search-icon">
        <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
          <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
        </svg>
      </div>

      <!-- 输入框 -->
      <input
        ref="inputRef"
        v-model="searchQuery"
        type="text"
        class="search-input"
        :placeholder="placeholder"
        @focus="handleFocus"
        @blur="handleBlur"
        @keydown.enter="handleSearch"
        @keydown.escape="handleClear"
      />

      <!-- 快捷键提示 -->
      <Transition name="fade">
        <span v-if="!isFocused && !searchQuery" class="shortcut-hint">
          按 <kbd>/</kbd> 搜索
        </span>
      </Transition>

      <!-- 清除按钮 -->
      <Transition name="fade">
        <button 
          v-if="searchQuery" 
          class="clear-btn"
          @click="handleClear"
        >
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
          </svg>
        </button>
      </Transition>
    </div>

    <!-- 搜索结果下拉 -->
    <Transition name="slide-down">
      <div v-if="showResults && results.length > 0" class="search-results glass-panel">
        <div class="results-header">
          找到 {{ results.length }} 个结果
        </div>
        <div class="results-list">
          <div 
            v-for="(item, index) in results" 
            :key="item.id"
            class="result-item"
            :class="{ 'is-active': activeIndex === index }"
            @click="selectResult(item)"
            @mouseenter="activeIndex = index"
          >
            <div class="result-icon">
              <img v-if="item.icon" :src="item.icon" :alt="item.title" />
              <span v-else>{{ item.title?.charAt(0) }}</span>
            </div>
            <div class="result-content">
              <div class="result-title">{{ item.title }}</div>
              <div class="result-category">{{ item.categoryName }}</div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useLinkStore } from '../../stores/link'
import { useDebounceFn } from '@vueuse/core'

const props = defineProps({
  placeholder: {
    type: String,
    default: '搜索链接...'
  }
})

const emit = defineEmits(['search', 'select'])

const linkStore = useLinkStore()
const inputRef = ref(null)
const searchQuery = ref('')
const isFocused = ref(false)
const showResults = ref(false)
const activeIndex = ref(0)

const results = computed(() => linkStore.filteredLinks)

// 防抖搜索
const debouncedSearch = useDebounceFn((query) => {
  linkStore.setSearchQuery(query)
  emit('search', query)
}, 200)

watch(searchQuery, (newVal) => {
  debouncedSearch(newVal)
  activeIndex.value = 0
  showResults.value = !!newVal.trim()
})

function handleFocus() {
  isFocused.value = true
  if (searchQuery.value) {
    showResults.value = true
  }
}

function handleBlur() {
  isFocused.value = false
  // 延迟关闭以允许点击结果
  setTimeout(() => {
    showResults.value = false
  }, 200)
}

function handleSearch() {
  if (results.value.length > 0 && activeIndex.value >= 0) {
    selectResult(results.value[activeIndex.value])
  }
}

function handleClear() {
  searchQuery.value = ''
  linkStore.clearSearch()
  showResults.value = false
}

function selectResult(item) {
  emit('select', item)
  showResults.value = false
  searchQuery.value = ''
  linkStore.clearSearch()
}

// 全局快捷键 /
function handleGlobalKeydown(e) {
  if (e.key === '/' && document.activeElement !== inputRef.value) {
    e.preventDefault()
    inputRef.value?.focus()
  }
}

// 上下选择结果
function handleArrowKeys(e) {
  if (!showResults.value || results.value.length === 0) return
  
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    activeIndex.value = (activeIndex.value + 1) % results.value.length
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    activeIndex.value = (activeIndex.value - 1 + results.value.length) % results.value.length
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleGlobalKeydown)
  document.addEventListener('keydown', handleArrowKeys)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleGlobalKeydown)
  document.removeEventListener('keydown', handleArrowKeys)
})

// 暴露方法供外部调用
defineExpose({
  focus: () => inputRef.value?.focus(),
  clear: handleClear
})
</script>

<style scoped>
.search-bar-wrapper {
  position: relative;
  width: 100%;
  max-width: 600px;
}

.search-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: rgba(45, 38, 64, 0.4);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px; /* More rounded */
}

.search-bar:hover {
  background: rgba(45, 38, 64, 0.6);
  border-color: rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.search-bar.is-focused {
  background: rgba(45, 38, 64, 0.8);
  border-color: var(--hsr-cyan);
  box-shadow: 0 0 0 2px rgba(0, 212, 255, 0.2), var(--hsr-shadow-glow-cyan);
  transform: scale(1.01);
}

.search-icon {
  color: var(--hsr-text-muted);
  flex-shrink: 0;
  transition: all 0.3s ease;
}

.search-bar.is-focused .search-icon {
  color: var(--hsr-cyan);
  transform: scale(1.1);
}

.search-input {
  flex: 1;
  background: transparent;
  border: none;
  color: var(--hsr-text-primary);
  font-size: 15px;
  outline: none;
  padding: 0;
}

.search-input::placeholder {
  color: var(--hsr-text-muted);
  transition: color 0.3s ease;
}

.search-bar.is-focused .search-input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.shortcut-hint {
  color: var(--hsr-text-muted);
  font-size: 12px;
  white-space: nowrap;
  pointer-events: none;
}

.shortcut-hint kbd {
  display: inline-block;
  padding: 2px 6px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 4px;
  font-family: inherit;
  font-size: 11px;
  color: var(--hsr-text-secondary);
}

.clear-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--hsr-text-muted);
  padding: 4px;
  border-radius: 50%;
  transition: all 0.2s ease;
  margin-right: -4px;
}

.clear-btn:hover {
  color: var(--hsr-text-primary);
  background: rgba(255, 255, 255, 0.15);
  transform: rotate(90deg);
}

/* 搜索结果 */
.search-results {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  max-height: 400px;
  overflow-y: auto;
  z-index: 100;
}

.results-header {
  padding: 12px 16px;
  font-size: 12px;
  color: var(--hsr-text-muted);
  border-bottom: 1px solid var(--hsr-border);
}

.results-list {
  padding: 8px;
}

.result-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border-radius: var(--hsr-radius-md);
  cursor: pointer;
  transition: all 0.15s ease;
}

.result-item:hover,
.result-item.is-active {
  background: rgba(0, 212, 255, 0.1);
}

.result-icon {
  width: 32px;
  height: 32px;
  border-radius: var(--hsr-radius-sm);
  background: rgba(139, 122, 173, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.result-icon img {
  width: 20px;
  height: 20px;
  object-fit: contain;
}

.result-icon span {
  font-size: 14px;
  font-weight: 600;
  color: var(--hsr-gold);
}

.result-content {
  flex: 1;
  min-width: 0;
}

.result-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--hsr-text-primary);
}

.result-category {
  font-size: 12px;
  color: var(--hsr-text-muted);
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

.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.2s ease;
}

.slide-down-enter-from,
.slide-down-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>
