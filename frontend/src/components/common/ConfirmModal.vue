<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="visible" class="modal-overlay" @click.self="handleClose">
        <div class="confirm-modal glass-modal animate-scale-in">
          <div class="modal-icon" :class="{ 'is-danger': danger }">
            <svg v-if="danger" viewBox="0 0 24 24" width="32" height="32" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" width="32" height="32" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
          </div>

          <h3 class="modal-title">{{ title }}</h3>
          <p class="modal-message">{{ message }}</p>

          <div class="modal-actions">
            <button class="glass-button" @click="handleClose">
              {{ cancelText }}
            </button>
            <button 
              class="glass-button"
              :class="danger ? 'btn-danger' : 'glass-button-primary'"
              @click="handleConfirm"
            >
              {{ confirmText }}
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
const props = defineProps({
  visible: Boolean,
  title: {
    type: String,
    default: '确认操作'
  },
  message: {
    type: String,
    default: '确定要执行此操作吗？'
  },
  confirmText: {
    type: String,
    default: '确认'
  },
  cancelText: {
    type: String,
    default: '取消'
  },
  danger: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:visible', 'confirm', 'cancel'])

function handleClose() {
  emit('update:visible', false)
  emit('cancel')
}

function handleConfirm() {
  emit('confirm')
}
</script>

<style scoped>
.confirm-modal {
  width: 90%;
  max-width: 360px;
  padding: 32px;
  text-align: center;
}

.modal-icon {
  width: 56px;
  height: 56px;
  margin: 0 auto 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: rgba(0, 212, 255, 0.1);
  color: var(--hsr-cyan);
}

.modal-icon.is-danger {
  background: rgba(255, 71, 87, 0.1);
  color: #ff4757;
}

.modal-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--hsr-text-primary);
  margin: 0 0 8px 0;
}

.modal-message {
  font-size: 14px;
  color: var(--hsr-text-secondary);
  margin: 0 0 24px 0;
  line-height: 1.5;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}

.modal-actions .glass-button {
  flex: 1;
  max-width: 120px;
}

.btn-danger {
  background: rgba(255, 71, 87, 0.2);
  border-color: rgba(255, 71, 87, 0.5);
  color: #ff4757;
}

.btn-danger:hover {
  background: rgba(255, 71, 87, 0.3);
  border-color: #ff4757;
  box-shadow: 0 0 20px rgba(255, 71, 87, 0.3);
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
