<template>
  <div class="category-section" :class="{ 'is-collapsed': isCollapsed }">
    <!-- 分类头部 -->
    <div class="category-header" @click="toggleCollapse">
      <div class="header-left">
        <button class="collapse-btn" :class="{ 'is-collapsed': isCollapsed }">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
            <path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/>
          </svg>
        </button>
        <span v-if="category.icon" class="category-icon">{{ category.icon }}</span>
        <h3 class="category-name">{{ category.name }}</h3>
        <span class="link-count">{{ linkCount }}</span>
      </div>
      
      <div class="header-actions" @click.stop v-if="isLoggedIn">
        <button class="action-btn" @click="handleEdit" title="编辑分类">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
            <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
        </button>
        <button class="action-btn add-btn" @click="handleAddLink" title="添加链接">
          <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
            <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- 链接网格 -->
    <Transition name="collapse">
      <div v-show="!isCollapsed" class="category-content">
        <draggable
          v-model="sortedLinks"
          :group="{ name: 'links', pull: true, put: true }"
          item-key="id"
          :animation="200"
          :disabled="!isLoggedIn"
          ghost-class="link-ghost"
          drag-class="link-drag"
          @change="handleDragChange"
          class="links-grid"
        >
          <template #item="{ element }">
            <LinkCard
              :link="element"
              :is-dragging="draggedId === element.id"
              @click="handleLinkClick(element)"
              @edit="handleEditLink(element)"
              @delete="handleDeleteLink(element)"
            />
          </template>
        </draggable>

        <!-- 空状态 -->
        <div v-if="!links.length" class="empty-state">
          <span class="empty-icon">📭</span>
          <p>暂无链接</p>
          <button class="glass-button" @click="handleAddLink">添加第一个链接</button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import draggable from 'vuedraggable'
import LinkCard from '../link/LinkCard.vue'
import { useSettingsStore } from '../../stores/settings'
import { useLinkStore } from '../../stores/link'
import { useAuthStore } from '../../stores/auth'

const props = defineProps({
  category: {
    type: Object,
    required: true
  }
})

const emit = defineEmits([
  'edit',
  'add-link',
  'edit-link',
  'delete-link',
  'link-click',
  'reorder'
])

const linkStore = useLinkStore()
const settingsStore = useSettingsStore()
const authStore = useAuthStore()

const isCollapsed = ref(false)
const draggedId = ref(null)

const links = computed(() => props.category.links || [])
const linkCount = computed(() => links.value.length)
const isLoggedIn = computed(() => authStore.isLoggedIn)

// 用于拖拽排序的响应式列表
const sortedLinks = ref([...links.value])

watch(links, (newLinks) => {
  sortedLinks.value = [...newLinks]
}, { deep: true })

const dragOptions = computed(() => ({
  animation: 200,
  group: 'links',
  // 只有登录后才允许拖拽
  disabled: !isLoggedIn.value,
  ghostClass: 'link-ghost',
  dragClass: 'link-drag',
  delay: 100,
  delayOnTouchOnly: true
}))

function toggleCollapse() {
  isCollapsed.value = !isCollapsed.value
}

function handleEdit() {
  if (!isLoggedIn.value) return
  emit('edit', props.category)
}

function handleAddLink() {
  if (!isLoggedIn.value) return
  emit('add-link', props.category.id)
}

function handleEditLink(link) {
  if (!isLoggedIn.value) return
  emit('edit-link', link)
}

function handleDeleteLink(link) {
  if (!isLoggedIn.value) return
  emit('delete-link', link)
}

function handleLinkClick(link) {
  emit('link-click', link)
}

async function handleDragChange(evt) {
  if (evt.added || evt.moved) {
    const linkIds = sortedLinks.value.map(l => l.id)
    emit('reorder', {
      categoryId: props.category.id,
      linkIds,
      addedLink: evt.added?.element,
      fromCategoryId: evt.added?.element?.categoryId
    })
  }
}
</script>

<style scoped>
.category-section {
  margin-bottom: 24px;
}

.category-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: rgba(45, 38, 64, 0.4);
  border-radius: var(--hsr-radius-lg);
  cursor: pointer;
  transition: all 0.2s ease;
  user-select: none;
}

.category-header:hover {
  background: rgba(45, 38, 64, 0.6);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 10px;
}

.collapse-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  color: var(--hsr-text-muted);
  transition: transform 0.2s ease;
}

.collapse-btn.is-collapsed {
  transform: rotate(-90deg);
}

.category-icon {
  font-size: 18px;
}

.category-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0;
}

.link-count {
  font-size: 12px;
  padding: 2px 8px;
  background: rgba(139, 122, 173, 0.2);
  border-radius: 10px;
  color: var(--hsr-text-secondary);
}

.header-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.category-header:hover .header-actions {
  opacity: 1;
}

.action-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--hsr-radius-sm);
  color: var(--hsr-text-muted);
  transition: all 0.2s ease;
}

.action-btn:hover {
  color: var(--hsr-cyan);
  background: rgba(0, 212, 255, 0.1);
}

.action-btn.add-btn:hover {
  color: var(--hsr-gold);
  background: rgba(255, 215, 0, 0.1);
}

.category-content {
  margin-top: 12px;
  padding-left: 16px;
}

.links-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 12px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: var(--hsr-text-muted);
  text-align: center;
}

.empty-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.empty-state p {
  margin: 0 0 16px 0;
}

/* 拖拽样式 */
.link-ghost {
  opacity: 0.4;
  background: rgba(0, 212, 255, 0.1);
}

.link-drag {
  opacity: 0.9;
  transform: scale(1.02);
  box-shadow: var(--hsr-shadow-lg), var(--hsr-shadow-glow-cyan);
}

/* 折叠动画 */
.collapse-enter-active,
.collapse-leave-active {
  transition: all 0.3s ease;
  overflow: hidden;
}

.collapse-enter-from,
.collapse-leave-to {
  opacity: 0;
  max-height: 0;
  margin-top: 0;
}

.collapse-enter-to,
.collapse-leave-from {
  max-height: 1000px;
}
</style>
