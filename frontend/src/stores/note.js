import { defineStore } from 'pinia'
import request from '../api/request'

export const useNoteStore = defineStore('note', {
    state: () => ({
        notes: []
    }),

    actions: {
        async fetchNotes() {
            try {
                const res = await request.get('/notes')
                this.notes = res.data || []
            } catch (error) {
                console.error('获取笔记失败', error)
            }
        },

        async createNote(content) {
            const res = await request.post('/notes', { content })
            // 插入到开头
            this.notes.unshift(res.data)
            return res.data
        },

        async updateNote(id, content) {
            const res = await request.put(`/notes/${id}`, { content })
            const index = this.notes.findIndex(n => n.id === id)
            if (index !== -1) {
                this.notes[index] = res.data
            }
            return res.data
        },

        async deleteNote(id) {
            await request.delete(`/notes/${id}`)
            this.notes = this.notes.filter(n => n.id !== id)
        }
    }
})
