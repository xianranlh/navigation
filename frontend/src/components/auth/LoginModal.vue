<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click.self="handleClose">
        <div class="login-modal glass-modal animate-scale-in">
          <div class="modal-header">
            <h3 class="modal-title">管理员登录</h3>
            <button class="close-btn" @click="handleClose">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <form @submit.prevent="handleSubmit" class="login-form">
            <div class="form-group">
              <label>用户名</label>
              <input 
                v-model="form.username" 
                type="text" 
                class="glass-input"
                placeholder="请输入用户名"
                required
                autofocus
              >
            </div>

            <div class="form-group">
              <label>密码</label>
              <input 
                v-model="form.password" 
                type="password" 
                class="glass-input"
                placeholder="请输入密码"
                required
              >
            </div>

            <div class="form-actions">
              <button 
                type="submit" 
                class="glass-button glass-button-primary submit-btn"
                :disabled="loading"
              >
                <span v-if="loading" class="spinner"></span>
                <span v-else>登录</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useAuthStore } from '../../stores/auth'

const props = defineProps({
  visible: Boolean
})

const emit = defineEmits(['update:visible', 'success'])

const authStore = useAuthStore()
const loading = ref(false)

const form = reactive({
  username: '',
  password: ''
})

function handleClose() {
  emit('update:visible', false)
  form.username = ''
  form.password = ''
}

async function handleSubmit() {
  if (loading.value) return
  
  loading.value = true
  try {
    const success = await authStore.login(form.username, form.password)
    if (success) {
      emit('success')
      handleClose()
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-modal {
  width: 90%;
  max-width: 400px;
  padding: 24px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0;
}

.close-btn {
  color: var(--hsr-text-muted);
  padding: 4px;
  border-radius: var(--hsr-radius-sm);
  transition: all 0.2s ease;
}

.close-btn:hover {
  color: var(--hsr-text-primary);
  background: rgba(255, 255, 255, 0.1);
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 14px;
  color: var(--hsr-text-secondary);
}

.submit-btn {
  width: 100%;
  justify-content: center;
  margin-top: 8px;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
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
