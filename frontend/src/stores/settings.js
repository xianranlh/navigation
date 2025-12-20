import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useSettingsStore = defineStore('settings', () => {
    // 主题设置
    const theme = ref(localStorage.getItem('nav-theme') || 'dark')
    const layout = ref(localStorage.getItem('nav-layout') || 'grid')
    const showDescription = ref(localStorage.getItem('nav-show-desc') !== 'false')
    const cardSize = ref(localStorage.getItem('nav-card-size') || 'medium')

    // 背景设置
    const backgroundType = ref(localStorage.getItem('nav-bg-type') || 'starfield')
    const customBackground = ref(localStorage.getItem('nav-bg-custom') || '')

    // 持久化
    watch(theme, (val) => localStorage.setItem('nav-theme', val))
    watch(layout, (val) => localStorage.setItem('nav-layout', val))
    watch(showDescription, (val) => localStorage.setItem('nav-show-desc', val))
    watch(cardSize, (val) => localStorage.setItem('nav-card-size', val))
    watch(backgroundType, (val) => localStorage.setItem('nav-bg-type', val))
    watch(customBackground, (val) => localStorage.setItem('nav-bg-custom', val))

    function setTheme(newTheme) {
        theme.value = newTheme
        document.documentElement.setAttribute('data-theme', newTheme)
    }

    function setLayout(newLayout) {
        layout.value = newLayout
    }

    function toggleDescription() {
        showDescription.value = !showDescription.value
    }

    function setCardSize(size) {
        cardSize.value = size
    }

    function setBackground(type, customUrl = '') {
        backgroundType.value = type
        if (type === 'custom') {
            customBackground.value = customUrl
        }
    }

    // 初始化主题
    function initTheme() {
        document.documentElement.setAttribute('data-theme', theme.value)
    }

    return {
        theme,
        layout,
        showDescription,
        cardSize,
        backgroundType,
        customBackground,
        setTheme,
        setLayout,
        toggleDescription,
        setCardSize,
        setBackground,
        initTheme
    }
})
