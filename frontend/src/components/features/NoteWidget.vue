<template>
  <div class="note-widget glass-card" :class="{ 'is-expanded': isExpanded }">
    <div class="note-header" @click="toggleExpand">
      <div class="header-left">
        <span class="icon">📝</span>
        <span class="title">便签</span>
        <span class="count" v-if="notes.length">{{ notes.length }}</span>
      </div>
      <button v-if="isExpanded && isLoggedIn" class="add-btn" @click.stop="handleAdd">
        <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
          <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
        </svg>
      </button>
    </div>
    
    <div v-if="isExpanded" class="note-content">
      <!-- 列表 -->
      <div v-if="notes.length > 0" class="note-list">
        <div v-for="note in notes" :key="note.id" class="note-item glass-panel">
          <div v-if="editingId === note.id" class="edit-area">
            <textarea 
              v-model="editContent" 
              ref="editInput"
              @blur="saveEdit(note)"
              @keydown.enter.prevent="saveEdit(note)"
            ></textarea>
          </div>
          <div v-else class="view-area" @click="startEdit(note)">
            <p class="note-text">{{ note.content }}</p>
            <div class="note-meta">
              <span>{{ formatDate(note.updatedAt) }}</span>
              <button v-if="isLoggedIn" class="delete-btn" @click.stop="handleDelete(note.id)">×</button>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 空状态 -->
      <div v-else class="empty-note">
        <span v-if="isLoggedIn">点击右上角 + 新建便签</span>
        <span v-else>暂无便签</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useNoteStore } from '../../stores/note'
import { useAuthStore } from '../../stores/auth'
import dayjs from 'dayjs'

const noteStore = useNoteStore()
const authStore = useAuthStore()

const isExpanded = ref(false)
const editingId = ref(null)
const editContent = ref('')
const editInput = ref(null)

const notes = computed(() => noteStore.notes)
const isLoggedIn = computed(() => authStore.isLoggedIn)

function toggleExpand() {
  isExpanded.value = !isExpanded.value
  if (isExpanded.value && notes.value.length === 0) {
    noteStore.fetchNotes()
  }
}

function formatDate(date) {
  return dayjs(date).format('MM-DD HH:mm')
}

async function handleAdd() {
  if (!isLoggedIn.value) return
  try {
    const newNote = await noteStore.createNote('新便签...')
    startEdit(newNote)
  } catch (e) {
    // ignore
  }
}

function startEdit(note) {
  if (!isLoggedIn.value) return
  editingId.value = note.id
  editContent.value = note.content
  nextTick(() => {
    editInput.value?.[0]?.focus()
  })
}

async function saveEdit(note) {
  if (!editingId.value) return
  
  if (editContent.value.trim() !== note.content) {
    if (!editContent.value.trim()) {
      // 如果清空了，询问删除或保留？这里直接保留空或者恢复？
      // 简单起见，且允许删除，如果空则删除
      await handleDelete(note.id)
    } else {
      await noteStore.updateNote(note.id, editContent.value)
    }
  }
  editingId.value = null
}

async function handleDelete(id) {
  if (!confirm('确定删除此便签吗？')) return
  await noteStore.deleteNote(id)
}

onMounted(() => {
  noteStore.fetchNotes()
})
</script>

<style scoped>
.note-widget {
  position: fixed;
  bottom: 24px;
  right: 24px;
  width: 280px;
  max-height: 48px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  z-index: 50;
  display: flex;
  flex-direction: column;
}

.note-widget.is-expanded {
  max-height: 500px;
}

.note-header {
  height: 48px;
  padding: 0 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  background: rgba(45, 38, 64, 0.6);
  border-bottom: 1px solid transparent;
}

.note-widget.is-expanded .note-header {
  border-bottom-color: rgba(255, 255, 255, 0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon {
  font-size: 18px;
}

.title {
  font-weight: 600;
  color: var(--hsr-text-primary);
}

.count {
  font-size: 12px;
  padding: 2px 6px;
  background: var(--hsr-accent-bg);
  border-radius: 10px;
  color: var(--hsr-text-secondary);
}

.add-btn {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  color: var(--hsr-text-muted);
  transition: all 0.2s;
}

.add-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: var(--hsr-text-primary);
}

.note-content {
  flex: 1;
  overflow-y: auto;
  padding: 12px;
  background: rgba(45, 38, 64, 0.4);
}

.note-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.note-item {
  padding: 8px 12px;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.05);
  cursor: pointer;
  transition: all 0.2s;
}

.note-item:hover {
  border-color: rgba(0, 212, 255, 0.3);
}

.note-text {
  margin: 0 0 4px 0;
  font-size: 14px;
  color: var(--hsr-text-primary);
  white-space: pre-wrap;
  word-break: break-all;
}

.note-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: var(--hsr-text-muted);
}

.delete-btn {
  opacity: 0;
  color: var(--hsr-red);
  font-size: 16px;
  padding: 0 4px;
}

.note-item:hover .delete-btn {
  opacity: 1;
}

.edit-area textarea {
  width: 100%;
  min-height: 60px;
  background: transparent;
  border: none;
  color: var(--hsr-text-primary);
  font-size: 14px;
  resize: vertical;
  outline: none;
}

.empty-note {
  text-align: center;
  padding: 20px 0;
  color: var(--hsr-text-muted);
  font-size: 14px;
}
</style>
