<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click.self="handleClose">
        <div class="category-modal glass-modal animate-scale-in">
          <div class="modal-header">
            <h3 class="modal-title">
              {{ isEdit ? '编辑分类' : '新建分类' }}
            </h3>
            <button class="close-btn" @click="handleClose">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <div class="modal-body">
            <div class="form-group">
              <label class="form-label">分类名称</label>
              <input
                v-model="form.name"
                type="text"
                class="glass-input"
                placeholder="例如：常用工具"
                maxlength="20"
              />
            </div>

            <div class="form-group">
              <label class="form-label">图标（可选）</label>
              <div class="icon-picker">
                <button
                  v-for="icon in iconOptions"
                  :key="icon"
                  class="icon-option"
                  :class="{ 'is-selected': form.icon === icon }"
                  @click="form.icon = icon"
                >
                  {{ icon }}
                </button>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">描述（可选）</label>
              <input
                v-model="form.description"
                type="text"
                class="glass-input"
                placeholder="简短描述"
                maxlength="50"
              />
            </div>
          </div>

          <div class="modal-footer">
            <button class="glass-button" @click="handleClose">取消</button>
            <button 
              class="glass-button glass-button-primary"
              :disabled="!form.name || isSubmitting"
              @click="handleSubmit"
            >
              {{ isEdit ? '保存' : '创建' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useCategoryStore } from '../../stores/category'
import { useToastStore } from '../../stores/toast'

const props = defineProps({
  visible: Boolean,
  editCategory: Object
})

const emit = defineEmits(['update:visible', 'success'])

const categoryStore = useCategoryStore()
const toast = useToastStore()

const isSubmitting = ref(false)
const form = reactive({
  name: '',
  icon: '',
  description: ''
})

const iconOptions = ['📁', '🔧', '💻', '🎮', '📚', '🎵', '📷', '🛒', '💼', '🌐', '⭐', '🚀']

const isEdit = computed(() => !!props.editCategory)

watch(() => props.editCategory, (cat) => {
  if (cat) {
    form.name = cat.name
    form.icon = cat.icon || ''
    form.description = cat.description || ''
  } else {
    form.name = ''
    form.icon = ''
    form.description = ''
  }
}, { immediate: true })

watch(() => props.visible, (visible) => {
  if (!visible && !props.editCategory) {
    form.name = ''
    form.icon = ''
    form.description = ''
  }
})

async function handleSubmit() {
  if (!form.name || isSubmitting.value) return

  isSubmitting.value = true
  try {
    const data = {
      name: form.name,
      icon: form.icon,
      description: form.description
    }

    if (isEdit.value) {
      await categoryStore.updateCategory(props.editCategory.id, data)
      toast.success('分类已更新')
    } else {
      await categoryStore.createCategory(data)
      toast.success('分类创建成功')
    }

    emit('success')
    handleClose()
  } catch (e) {
    toast.error(isEdit.value ? '更新失败' : '创建失败')
  } finally {
    isSubmitting.value = false
  }
}

function handleClose() {
  emit('update:visible', false)
}
</script>

<style scoped>
.category-modal {
  width: 90%;
  max-width: 420px;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--hsr-border);
}

.modal-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0;
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
  font-size: 13px;
  font-weight: 500;
  color: var(--hsr-text-secondary);
}

.icon-picker {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.icon-option {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--hsr-radius-md);
  background: rgba(45, 38, 64, 0.5);
  border: 1px solid var(--hsr-border);
  font-size: 18px;
  transition: all 0.2s ease;
}

.icon-option:hover {
  border-color: var(--hsr-cyan);
  transform: scale(1.1);
}

.icon-option.is-selected {
  background: rgba(0, 212, 255, 0.2);
  border-color: var(--hsr-cyan);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 24px;
  border-top: 1px solid var(--hsr-border);
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
</style>
