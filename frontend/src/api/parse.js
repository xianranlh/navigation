import request from './request'

// 解析URL信息（自动获取标题、描述、图标）
export function parseUrl(url) {
    return request.post('/parse/url', { url })
}

// 批量解析URL
export function batchParseUrls(urls) {
    return request.post('/parse/batch', { urls })
}

// 获取网站图标
export function getFavicon(url) {
    return request.get('/parse/favicon', { params: { url } })
}
