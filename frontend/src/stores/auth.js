import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as authApi from '../api/auth'
import { useToastStore } from './toast'

export const useAuthStore = defineStore('auth', () => {
    const token = ref(localStorage.getItem('nav-token') || '')
    const user = ref(JSON.parse(localStorage.getItem('user') || 'null'))
    const toast = useToastStore()

    const isLoggedIn = computed(() => !!token.value)
    const isAdmin = computed(() => user.value?.role === 'admin')

    async function login(username, password) {
        try {
            const res = await authApi.login({ username, password })
            token.value = res.data.token
            user.value = res.data.user

            localStorage.setItem('nav-token', token.value)
            localStorage.setItem('user', JSON.stringify(user.value))

            toast.success('登录成功')
            return true
        } catch (error) {
            toast.error(error.message || '登录失败')
            return false
        }
    }

    function logout() {
        token.value = ''
        user.value = null
        localStorage.removeItem('nav-token')
        localStorage.removeItem('user')
        toast.success('已退出登录')
    }

    async function checkAuth() {
        if (!token.value) return false
        try {
            await authApi.getInfo()
            return true
        } catch (error) {
            logout()
            return false
        }
    }

    return {
        token,
        user,
        isLoggedIn,
        isAdmin,
        login,
        logout,
        checkAuth
    }
})
