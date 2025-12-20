import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import * as linkApi from '../api/link'
import { useCategoryStore } from './category'

export const useLinkStore = defineStore('link', () => {
    const categoryStore = useCategoryStore()

    // 状态
    const loading = ref(false)
    const searchQuery = ref('')
    const searchResults = ref([])

    // 所有链接（从分类中提取）
    const allLinks = computed(() => {
        return categoryStore.categories.flatMap(cat =>
            (cat.links || []).map(link => ({ ...link, categoryName: cat.name }))
        )
    })

    // 搜索过滤
    const filteredLinks = computed(() => {
        if (!searchQuery.value.trim()) return []

        const query = searchQuery.value.toLowerCase()
        return allLinks.value.filter(link =>
            link.title.toLowerCase().includes(query) ||
            link.description?.toLowerCase().includes(query) ||
            link.url.toLowerCase().includes(query)
        )
    })

    // 热门链接
    const popularLinks = computed(() => {
        return [...allLinks.value]
            .sort((a, b) => (b.clickCount || 0) - (a.clickCount || 0))
            .slice(0, 10)
    })

    // 方法
    async function createLink(data) {
        loading.value = true
        try {
            const res = await linkApi.createLink(data)
            categoryStore.addLinkToCategory(data.categoryId, res.data)
            return res.data
        } finally {
            loading.value = false
        }
    }

    async function updateLink(id, categoryId, data) {
        loading.value = true
        try {
            const res = await linkApi.updateLink(id, data)
            categoryStore.updateLinkInCategory(categoryId, id, res.data)
            return res.data
        } finally {
            loading.value = false
        }
    }

    async function deleteLink(id, categoryId) {
        loading.value = true
        try {
            await linkApi.deleteLink(id)
            categoryStore.removeLinkFromCategory(categoryId, id)
        } finally {
            loading.value = false
        }
    }

    async function recordClick(id) {
        try {
            await linkApi.recordClick(id)
            // 更新本地点击数
            for (const cat of categoryStore.categories) {
                const link = cat.links?.find(l => l.id === id)
                if (link) {
                    link.clickCount = (link.clickCount || 0) + 1
                    break
                }
            }
        } catch (e) {
            console.error('Failed to record click:', e)
        }
    }

    async function moveLink(linkId, fromCategoryId, toCategoryId) {
        const category = categoryStore.categories.find(c => c.id === fromCategoryId)
        const link = category?.links?.find(l => l.id === linkId)

        if (!link) return

        // 乐观更新
        categoryStore.moveLinkBetweenCategories(fromCategoryId, toCategoryId, link)

        try {
            await linkApi.updateLink(linkId, { categoryId: toCategoryId })
        } catch (e) {
            // 回滚
            categoryStore.moveLinkBetweenCategories(toCategoryId, fromCategoryId, link)
            throw e
        }
    }

    async function reorderLinks(categoryId, linkIds) {
        const category = categoryStore.categories.find(c => c.id === categoryId)
        if (!category) return

        const oldLinks = [...(category.links || [])]

        // 乐观更新
        category.links = linkIds.map((id, index) => {
            const link = oldLinks.find(l => l.id === id)
            return { ...link, sortOrder: index }
        })

        try {
            await linkApi.reorderLinks(categoryId, linkIds)
        } catch (e) {
            category.links = oldLinks
            throw e
        }
    }

    function setSearchQuery(query) {
        searchQuery.value = query
    }

    function clearSearch() {
        searchQuery.value = ''
        searchResults.value = []
    }

    return {
        loading,
        searchQuery,
        searchResults,
        allLinks,
        filteredLinks,
        popularLinks,
        createLink,
        updateLink,
        deleteLink,
        recordClick,
        moveLink,
        reorderLinks,
        setSearchQuery,
        clearSearch
    }
})
