import request from './request'

// 获取分类列表
export function getCategories(params = {}) {
    return request.get('/categories', { params })
}

// 获取单个分类
export function getCategoryById(id) {
    return request.get(`/categories/${id}`)
}

// 创建分类
export function createCategory(data) {
    return request.post('/categories', data)
}

// 更新分类
export function updateCategory(id, data) {
    return request.put(`/categories/${id}`, data)
}

// 删除分类
export function deleteCategory(id) {
    return request.delete(`/categories/${id}`)
}

// 批量重排序分类
export function reorderCategories(categoryIds) {
    return request.put('/categories/reorder', { categoryIds })
}
