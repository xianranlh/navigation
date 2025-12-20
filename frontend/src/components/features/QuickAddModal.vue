<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click.self="handleClose">
        <div class="quick-add-modal glass-modal animate-scale-in">
          <!-- 头部 -->
          <div class="modal-header">
            <h3 class="modal-title">
              <span class="title-icon">✨</span>
              {{ isEdit ? '编辑链接' : '快速添加' }}
            </h3>
            <button class="close-btn" @click="handleClose">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <!-- 内容 -->
          <div class="modal-body">
            <!-- URL 输入 -->
            <div class="form-group">
              <label class="form-label">
                链接地址
                <span class="label-hint">粘贴后自动解析</span>
              </label>
              <div class="url-input-wrapper">
                <input
                  ref="urlInputRef"
                  v-model="form.url"
                  type="url"
                  class="glass-input"
                  placeholder="https://example.com"
                  @paste="handlePaste"
                  @blur="handleUrlBlur"
                />
                <button 
                  v-if="!isParsing && form.url"
                  class="parse-btn glass-button"
                  @click="parseUrl"
                  :disabled="isParsing"
                >
                  解析
                </button>
                <div v-if="isParsing" class="parsing-indicator">
                  <span class="spinner"></span>
                </div>
              </div>
            </div>

            <!-- 标题 -->
            <div class="form-group">
              <label class="form-label">标题</label>
              <input
                v-model="form.title"
                type="text"
                class="glass-input"
                placeholder="网站名称"
              />
            </div>

            <!-- 描述 -->
            <div class="form-group">
              <label class="form-label">描述（可选）</label>
              <input
                v-model="form.description"
                type="text"
                class="glass-input"
                placeholder="简短描述"
              />
            </div>

            <!-- 图标 -->
            <div class="form-group">
              <label class="form-label">
                图标（可选）
                <span class="label-hint">支持上传或输入URL</span>
              </label>
              <div class="icon-input-wrapper">
                <div class="icon-preview" @click="triggerUpload" title="点击上传图片">
                  <img v-if="form.icon" :src="form.icon" alt="icon" @error="form.icon = ''" />
                  <span v-else class="icon-placeholder-text">+</span>
                  <div v-if="isUploading" class="upload-loading">
                    <span class="spinner"></span>
                  </div>
                </div>
                <input
                  v-model="form.icon"
                  type="text"
                  class="glass-input"
                  placeholder="图标 URL（或点击左侧上传）"
                />
                <input
                  ref="fileInputRef"
                  type="file"
                  accept="image/*"
                  hidden
                  @change="handleFileUpload"
                />
              </div>
            </div>

            <!-- 分类选择 -->
            <div class="form-group">
              <label class="form-label">选择分类</label>
              <div class="category-selector">
                <button
                  v-for="cat in categories"
                  :key="cat.id"
                  class="category-option"
                  :class="{ 'is-selected': form.categoryId === cat.id }"
                  @click="form.categoryId = cat.id"
                >
                  <span v-if="cat.icon" class="cat-icon">{{ cat.icon }}</span>
                  {{ cat.name }}
                </button>
                <button class="category-option add-category" @click="showAddCategory = true">
                  + 新建分类
                </button>
              </div>
            </div>
          </div>

          <!-- 底部 -->
          <div class="modal-footer">
            <button class="glass-button" @click="handleClose">取消</button>
            <button 
              class="glass-button glass-button-primary"
              :disabled="!isValid || isSubmitting"
              @click="handleSubmit"
            >
              <span v-if="isSubmitting" class="spinner"></span>
              {{ isEdit ? '保存更改' : '添加链接' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, reactive, computed, watch, nextTick } from 'vue'
import { useCategoryStore } from '../../stores/category'
import { useLinkStore } from '../../stores/link'
import { useToastStore } from '../../stores/toast'
import * as parseApi from '../../api/parse'
import * as uploadApi from '../../api/upload'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  editLink: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:visible', 'success'])

const categoryStore = useCategoryStore()
const linkStore = useLinkStore()
const toast = useToastStore()

const urlInputRef = ref(null)
const fileInputRef = ref(null)
const isParsing = ref(false)
const isSubmitting = ref(false)
const isUploading = ref(false)
const showAddCategory = ref(false)

const form = reactive({
  url: '',
  title: '',
  description: '',
  icon: '',
  categoryId: null
})

const isEdit = computed(() => !!props.editLink)
const categories = computed(() => categoryStore.sortedCategories)
const isValid = computed(() => {
  return form.url && form.title && form.categoryId
})

// 监听编辑模式
watch(() => props.editLink, (link) => {
  if (link) {
    form.url = link.url
    form.title = link.title
    form.description = link.description || ''
    form.icon = link.icon || ''
    form.categoryId = link.categoryId
  }
}, { immediate: true })

// 打开时聚焦 URL 输入框
watch(() => props.visible, (visible) => {
  if (visible && !isEdit.value) {
    nextTick(() => urlInputRef.value?.focus())
  }
  if (!visible) {
    resetForm()
  }
})

function resetForm() {
  form.url = ''
  form.title = ''
  form.description = ''
  form.icon = ''
  form.categoryId = categories.value[0]?.id || null
}

async function handlePaste(e) {
  // 等待粘贴内容更新到输入框
  await nextTick()
  setTimeout(() => {
    if (form.url && isValidUrl(form.url)) {
      parseUrl()
    }
  }, 100)
}

function handleUrlBlur() {
  if (form.url && !form.title && isValidUrl(form.url)) {
    parseUrl()
  }
}

function isValidUrl(string) {
  try {
    new URL(string)
    return true
  } catch {
    return false
  }
}

async function parseUrl() {
  if (!form.url || isParsing.value) return
  
  isParsing.value = true
  try {
    const res = await parseApi.parseUrl(form.url)
    if (res.data) {
      if (!form.title) form.title = res.data.title || ''
      if (!form.description) form.description = res.data.description || ''
      if (!form.icon) form.icon = res.data.favicon || ''
    }
  } catch (e) {
    // 解析失败时尝试使用 Google Favicon API
    try {
      const domain = new URL(form.url).hostname
      form.icon = `https://www.google.com/s2/favicons?domain=${domain}&sz=64`
    } catch {}
  } finally {
    isParsing.value = false
  }
}

async function handleSubmit() {
  if (!isValid.value || isSubmitting.value) return
  
  isSubmitting.value = true
  try {
    const data = {
      url: form.url,
      title: form.title,
      description: form.description,
      icon: form.icon,
      categoryId: form.categoryId
    }

    if (isEdit.value) {
      await linkStore.updateLink(props.editLink.id, props.editLink.categoryId, data)
      toast.success('链接已更新')
    } else {
      await linkStore.createLink(data)
      toast.success('链接添加成功')
    }
    
    emit('success')
    handleClose()
  } catch (e) {
    toast.error(isEdit.value ? '更新失败' : '添加失败')
  } finally {
    isSubmitting.value = false
  }
}

function handleClose() {
  emit('update:visible', false)
}

// 图片上传
function triggerUpload() {
  fileInputRef.value?.click()
}

async function handleFileUpload(e) {
  const file = e.target.files[0]
  if (!file) return

  // 验证文件类型
  if (!file.type.startsWith('image/')) {
    toast.error('请选择图片文件')
    return
  }

  // 验证文件大小 (最大 100MB)
  if (file.size > 100 * 1024 * 1024) {
    toast.error('图片大小不能超过 100MB')
    return
  }

  isUploading.value = true
  try {
    const res = await uploadApi.uploadImage(file)
    if (res.data?.url) {
      form.icon = res.data.url
      toast.success('图标上传成功')
    }
  } catch (err) {
    toast.error('上传失败，请重试')
  } finally {
    isUploading.value = false
    e.target.value = '' // 清空 input，允许重复选择相同文件
  }
}
</script>

<style scoped>
.quick-add-modal {
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--hsr-border);
}

.modal-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 18px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0;
}

.title-icon {
  font-size: 20px;
}

.close-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: var(--hsr-radius-sm);
  color: var(--hsr-text-muted);
  transition: all 0.2s ease;
}

.close-btn:hover {
  color: var(--hsr-text-primary);
  background: rgba(255, 255, 255, 0.1);
}

.modal-body {
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 500;
  color: var(--hsr-text-secondary);
}

.label-hint {
  font-size: 11px;
  color: var(--hsr-cyan);
  opacity: 0.8;
}

.url-input-wrapper {
  display: flex;
  gap: 8px;
  position: relative;
}

.url-input-wrapper .glass-input {
  flex: 1;
}

.parse-btn {
  flex-shrink: 0;
}

.parsing-indicator {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
}

.spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid var(--hsr-border);
  border-top-color: var(--hsr-cyan);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.icon-input-wrapper {
  display: flex;
  gap: 12px;
  align-items: center;
}

.icon-preview {
  width: 40px;
  height: 40px;
  border-radius: var(--hsr-radius-md);
  background: rgba(139, 122, 173, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  overflow: hidden;
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
  border: 1px dashed var(--hsr-border);
}

.icon-preview:hover {
  border-color: var(--hsr-cyan);
  background: rgba(0, 212, 255, 0.1);
}

.icon-preview img {
  width: 28px;
  height: 28px;
  object-fit: contain;
}

.upload-loading {
  position: absolute;
  inset: 0;
  background: rgba(13, 10, 20, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-placeholder-text {
  font-size: 18px;
  color: var(--hsr-text-muted);
}

.icon-input-wrapper .glass-input {
  flex: 1;
}

.category-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.category-option {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  border-radius: var(--hsr-radius-md);
  background: rgba(45, 38, 64, 0.5);
  border: 1px solid var(--hsr-border);
  color: var(--hsr-text-secondary);
  font-size: 13px;
  transition: all 0.2s ease;
}

.category-option:hover {
  border-color: var(--hsr-cyan);
  color: var(--hsr-text-primary);
}

.category-option.is-selected {
  background: rgba(0, 212, 255, 0.15);
  border-color: var(--hsr-cyan);
  color: var(--hsr-cyan);
}

.category-option.add-category {
  border-style: dashed;
  color: var(--hsr-gold);
}

.category-option.add-category:hover {
  border-color: var(--hsr-gold);
}

.cat-icon {
  font-size: 14px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 24px;
  border-top: 1px solid var(--hsr-border);
}

/* 模态框动画 */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-active .quick-add-modal,
.modal-leave-active .quick-add-modal {
  transition: transform 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .quick-add-modal,
.modal-leave-to .quick-add-modal {
  transform: scale(0.9);
}
</style>
