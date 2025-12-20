import request from './request'

// 获取链接列表
export function getLinks(params = {}) {
    return request.get('/links', { params })
}

// 获取单个链接
export function getLinkById(id) {
    return request.get(`/links/${id}`)
}

// 创建链接
export function createLink(data) {
    return request.post('/links', data)
}

// 更新链接
export function updateLink(id, data) {
    return request.put(`/links/${id}`, data)
}

// 删除链接
export function deleteLink(id) {
    return request.delete(`/links/${id}`)
}

// 记录点击
export function recordClick(id) {
    return request.post(`/links/${id}/click`)
}

// 批量重排序链接
export function reorderLinks(categoryId, linkIds) {
    return request.put(`/links/reorder`, { categoryId, linkIds })
}

// 搜索链接
export function searchLinks(query) {
    return request.get('/links/search', { params: { q: query } })
}

// 批量删除链接
export function batchDeleteLinks(ids) {
    return request.post('/links/batch-delete', { ids })
}

// 批量移动链接
export function batchMoveLinks(ids, categoryId) {
    return request.post('/links/batch-move', { ids, categoryId })
}
