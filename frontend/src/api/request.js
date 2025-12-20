import axios from 'axios'
import { useToastStore } from '../stores/toast'

const request = axios.create({
    baseURL: '/api/v1',
    timeout: 15000,
    headers: {
        'Content-Type': 'application/json'
    }
})

// 请求拦截器
request.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('nav-token')
        if (token) {
            config.headers.Authorization = `Bearer ${token}`
        }
        return config
    },
    (error) => {
        return Promise.reject(error)
    }
)

// 响应拦截器
request.interceptors.response.use(
    (response) => {
        const res = response.data

        // 统一处理业务错误
        if (res.code && res.code !== 200) {
            const toast = useToastStore()
            toast.error(res.message || '请求失败')
            return Promise.reject(new Error(res.message || '请求失败'))
        }

        return res
    },
    (error) => {
        const toast = useToastStore()

        if (error.response) {
            const { status, data } = error.response

            switch (status) {
                case 401:
                    localStorage.removeItem('nav-token')
                    toast.error('登录已过期，请重新登录')
                    // 可以跳转到登录页
                    break
                case 403:
                    toast.error('没有权限执行此操作')
                    break
                case 404:
                    toast.error('请求的资源不存在')
                    break
                case 500:
                    toast.error('服务器错误，请稍后重试')
                    break
                default:
                    toast.error(data?.message || '网络请求失败')
            }
        } else if (error.request) {
            toast.error('网络连接失败，请检查网络')
        } else {
            toast.error('请求配置错误')
        }

        return Promise.reject(error)
    }
)

export default request
