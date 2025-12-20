import { createRouter, createWebHistory } from 'vue-router'

const routes = [
    {
        path: '/',
        name: 'Home',
        component: () => import('../views/HomePage.vue')
    },
    {
        path: '/admin',
        name: 'Admin',
        component: () => import('../views/AdminPage.vue')
    },
    {
        path: '/settings',
        name: 'Settings',
        component: () => import('../views/SettingsPage.vue')
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router
