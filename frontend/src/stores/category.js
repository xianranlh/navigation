import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as categoryApi from '../api/category'

export const useCategoryStore = defineStore('category', () => {
    // 状态
    const categories = ref([])
    const loading = ref(false)
    const error = ref(null)

    // 计算属性
    const sortedCategories = computed(() => {
        return [...categories.value].sort((a, b) => a.sortOrder - b.sortOrder)
    })

    const totalLinks = computed(() => {
        return categories.value.reduce((sum, cat) => sum + (cat.links?.length || 0), 0)
    })

    const getCategoryById = computed(() => {
        return (id) => categories.value.find(cat => cat.id === id)
    })

    // 方法
    async function fetchCategories() {
        loading.value = true
        error.value = null
        try {
            const res = await categoryApi.getCategories({ includeLinks: true })
            categories.value = res.data || []
        } catch (e) {
            error.value = e.message
            console.error('Failed to fetch categories:', e)
        } finally {
            loading.value = false
        }
    }

    async function createCategory(data) {
        const res = await categoryApi.createCategory(data)
        categories.value.push(res.data)
        return res.data
    }

    async function updateCategory(id, data) {
        const res = await categoryApi.updateCategory(id, data)
        const index = categories.value.findIndex(cat => cat.id === id)
        if (index !== -1) {
            categories.value[index] = { ...categories.value[index], ...res.data }
        }
        return res.data
    }

    async function deleteCategory(id) {
        await categoryApi.deleteCategory(id)
        categories.value = categories.value.filter(cat => cat.id !== id)
    }

    async function reorderCategories(newOrder) {
        // 乐观更新
        const oldCategories = [...categories.value]
        categories.value = newOrder.map((id, index) => {
            const cat = categories.value.find(c => c.id === id)
            return { ...cat, sortOrder: index }
        })

        try {
            await categoryApi.reorderCategories(newOrder)
        } catch (e) {
            // 回滚
            categories.value = oldCategories
            throw e
        }
    }

    // 本地添加链接到分类
    function addLinkToCategory(categoryId, link) {
        const category = categories.value.find(cat => cat.id === categoryId)
        if (category) {
            if (!category.links) category.links = []
            category.links.push(link)
        }
    }

    // 本地更新链接
    function updateLinkInCategory(categoryId, linkId, updatedLink) {
        const category = categories.value.find(cat => cat.id === categoryId)
        if (category && category.links) {
            const index = category.links.findIndex(l => l.id === linkId)
            if (index !== -1) {
                category.links[index] = { ...category.links[index], ...updatedLink }
            }
        }
    }

    // 本地删除链接
    function removeLinkFromCategory(categoryId, linkId) {
        const category = categories.value.find(cat => cat.id === categoryId)
        if (category && category.links) {
            category.links = category.links.filter(l => l.id !== linkId)
        }
    }

    // 移动链接到另一个分类
    function moveLinkBetweenCategories(fromCategoryId, toCategoryId, link) {
        removeLinkFromCategory(fromCategoryId, link.id)
        addLinkToCategory(toCategoryId, { ...link, categoryId: toCategoryId })
    }

    return {
        // 状态
        categories,
        loading,
        error,
        // 计算属性
        sortedCategories,
        totalLinks,
        getCategoryById,
        // 方法
        fetchCategories,
        createCategory,
        updateCategory,
        deleteCategory,
        reorderCategories,
        addLinkToCategory,
        updateLinkInCategory,
        removeLinkFromCategory,
        moveLinkBetweenCategories
    }
})
