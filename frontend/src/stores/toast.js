import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useToastStore = defineStore('toast', () => {
    const toasts = ref([])
    let idCounter = 0

    function show(message, type = 'info', duration = 3000) {
        const id = ++idCounter
        const toast = {
            id,
            message,
            type, // 'success' | 'error' | 'warning' | 'info'
            duration,
            visible: true
        }

        toasts.value.push(toast)

        if (duration > 0) {
            setTimeout(() => {
                remove(id)
            }, duration)
        }

        return id
    }

    function success(message, duration = 3000) {
        return show(message, 'success', duration)
    }

    function error(message, duration = 4000) {
        return show(message, 'error', duration)
    }

    function warning(message, duration = 3500) {
        return show(message, 'warning', duration)
    }

    function info(message, duration = 3000) {
        return show(message, 'info', duration)
    }

    function remove(id) {
        const index = toasts.value.findIndex(t => t.id === id)
        if (index !== -1) {
            toasts.value[index].visible = false
            setTimeout(() => {
                toasts.value = toasts.value.filter(t => t.id !== id)
            }, 300) // 等待退出动画
        }
    }

    function clear() {
        toasts.value = []
    }

    // 带撤销功能的提示
    function showWithUndo(message, undoCallback, duration = 5000) {
        const id = ++idCounter
        const toast = {
            id,
            message,
            type: 'undo',
            duration,
            visible: true,
            onUndo: () => {
                undoCallback()
                remove(id)
            }
        }

        toasts.value.push(toast)

        if (duration > 0) {
            setTimeout(() => {
                remove(id)
            }, duration)
        }

        return id
    }

    return {
        toasts,
        show,
        success,
        error,
        warning,
        info,
        remove,
        clear,
        showWithUndo
    }
})
