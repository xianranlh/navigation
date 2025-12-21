<template>
  <div class="home-page">
    <!-- 欢迎区域 -->
    <section class="welcome-section animate-fade-in-up">
      <h1 class="welcome-title">
        <span class="greeting">{{ greeting }}</span>
        <span class="title-text">开拓者</span>
      </h1>
      <p class="welcome-subtitle">快速访问你的星际航线</p>
    </section>

    <!-- 统计信息 -->
    <section class="stats-section animate-fade-in-up stagger-1">
      <div class="stat-item glass-card">
        <span class="stat-value">{{ categoryCount }}</span>
        <span class="stat-label">分类</span>
      </div>
      <div class="stat-item glass-card">
        <span class="stat-value">{{ linkCount }}</span>
        <span class="stat-label">链接</span>
      </div>
      <div class="stat-item glass-card">
        <span class="stat-value">{{ totalClicks }}</span>
        <span class="stat-label">访问</span>
      </div>
    </section>

    <!-- 加载状态 -->
    <div v-if="categoryStore.loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>正在加载数据...</p>
    </div>

    <!-- 分类列表 -->
    <section v-else class="categories-section">
      <CategorySection
        v-for="(category, index) in categories"
        :key="category.id"
        :category="category"
        :class="`animate-fade-in-up stagger-${Math.min(index + 2, 8)}`"
        @edit="handleEditCategory"
        @add-link="handleAddLink"
        @edit-link="handleEditLink"
        @delete-link="handleDeleteLink"
        @link-click="handleLinkClick"
        @reorder="handleReorder"
      />

      <!-- 空状态 -->
      <div v-if="!categories.length && !categoryStore.loading" class="empty-state glass-card">
        <span class="empty-icon">🌌</span>
        <h3>欢迎来到星穹导航</h3>
        <p>开始添加你的第一个分类和链接吧</p>
        <button class="glass-button glass-button-primary" @click="showAddCategory = true">
          创建分类
        </button>
      </div>
    </section>

    <!-- 编辑链接弹窗 -->
    <QuickAddModal
      v-model:visible="showEditLink"
      :edit-link="editingLink"
      @success="handleLinkUpdated"
    />

    <!-- 分类编辑弹窗 -->
    <CategoryEditModal
      v-model:visible="showAddCategory"
      :edit-category="editingCategory"
      @success="handleCategoryUpdated"
    />

    <!-- 删除确认弹窗 -->
    <ConfirmModal
      v-model:visible="showDeleteConfirm"
      title="确认删除"
      :message="`确定要删除「${deletingLink?.title}」吗？`"
      confirm-text="删除"
      :danger="true"
      @confirm="confirmDeleteLink"
    />
    <!-- 便签组件 -->
    <NoteWidget />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCategoryStore } from '../stores/category'
import { useLinkStore } from '../stores/link'
import { useToastStore } from '../stores/toast'
import CategorySection from '../components/category/CategorySection.vue'
import QuickAddModal from '../components/features/QuickAddModal.vue'
import CategoryEditModal from '../components/category/CategoryEditModal.vue'
import CategoryEditModal from '../components/category/CategoryEditModal.vue'
import ConfirmModal from '../components/common/ConfirmModal.vue'
import NoteWidget from '../components/features/NoteWidget.vue'

const categoryStore = useCategoryStore()
const linkStore = useLinkStore()
const toast = useToastStore()

// 状态
const showEditLink = ref(false)
const showAddCategory = ref(false)
const showDeleteConfirm = ref(false)
const editingLink = ref(null)
const editingCategory = ref(null)
const deletingLink = ref(null)
const addToCategoryId = ref(null)

// 计算属性
const categories = computed(() => categoryStore.sortedCategories)
const categoryCount = computed(() => categories.value.length)
const linkCount = computed(() => categoryStore.totalLinks)
const totalClicks = computed(() => {
  return categories.value.reduce((sum, cat) => {
    return sum + (cat.links || []).reduce((s, l) => s + (l.clickCount || 0), 0)
  }, 0)
})

const greeting = computed(() => {
  const hour = new Date().getHours()
  if (hour < 6) return '夜深了'
  if (hour < 12) return '早上好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  return '晚上好'
})

// 方法
function handleEditCategory(category) {
  editingCategory.value = category
  showAddCategory.value = true
}

function handleAddLink(categoryId) {
  addToCategoryId.value = categoryId
  editingLink.value = { categoryId }
  showEditLink.value = true
}

function handleEditLink(link) {
  editingLink.value = link
  showEditLink.value = true
}

function handleDeleteLink(link) {
  deletingLink.value = link
  showDeleteConfirm.value = true
}

async function confirmDeleteLink() {
  if (!deletingLink.value) return
  
  const link = deletingLink.value
  try {
    await linkStore.deleteLink(link.id, link.categoryId)
    toast.showWithUndo(
      `「${link.title}」已删除`,
      async () => {
        // 撤销删除
        await linkStore.createLink({
          ...link,
          categoryId: link.categoryId
        })
      }
    )
  } catch (e) {
    toast.error('删除失败')
  }
  
  showDeleteConfirm.value = false
  deletingLink.value = null
}

async function handleLinkClick(link) {
  await linkStore.recordClick(link.id)
  window.open(link.url, '_blank')
}

function handleLinkUpdated() {
  // 链接更新成功
}

function handleCategoryUpdated() {
  editingCategory.value = null
}

async function handleReorder({ categoryId, linkIds, addedLink, fromCategoryId }) {
  try {
    if (addedLink && fromCategoryId && fromCategoryId !== categoryId) {
      // 跨分类移动
      await linkStore.moveLink(addedLink.id, fromCategoryId, categoryId)
    } else {
      // 同分类排序
      await linkStore.reorderLinks(categoryId, linkIds)
    }
  } catch (e) {
    toast.error('排序保存失败')
    categoryStore.fetchCategories() // 刷新恢复
  }
}

// 初始化
onMounted(() => {
  categoryStore.fetchCategories()
})
</script>

<style scoped>
.home-page {
  padding-bottom: 40px;
}

/* 欢迎区域 */
.welcome-section {
  text-align: center;
  margin-bottom: 32px;
}

.welcome-title {
  font-size: 32px;
  font-weight: 700;
  margin: 0 0 8px 0;
  color: var(--hsr-text-primary);
}

.greeting {
  color: var(--hsr-gold);
  margin-right: 8px;
}

.title-text {
  background: linear-gradient(135deg, var(--hsr-cyan), var(--hsr-purple-light));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.welcome-subtitle {
  font-size: 15px;
  color: var(--hsr-text-secondary);
  margin: 0;
}

/* 统计区域 */
.stats-section {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-bottom: 40px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 32px;
  min-width: 100px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--hsr-cyan);
}

.stat-label {
  font-size: 13px;
  color: var(--hsr-text-muted);
  margin-top: 4px;
}

/* 加载状态 */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: var(--hsr-text-secondary);
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid var(--hsr-border);
  border-top-color: var(--hsr-cyan);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 分类区域 */
.categories-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 空状态 */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.empty-state h3 {
  font-size: 20px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0 0 8px 0;
}

.empty-state p {
  color: var(--hsr-text-secondary);
  margin: 0 0 24px 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .welcome-title {
    font-size: 24px;
  }

  .stats-section {
    gap: 12px;
  }

  .stat-item {
    padding: 12px 20px;
  }

  .stat-value {
    font-size: 22px;
  }
}
</style>
