const axios = require('axios')
const cheerio = require('cheerio')

// 解析 URL 获取标题、描述、图标
const parseUrl = async (req, res, next) => {
    try {
        const { url } = req.body

        if (!url) {
            return res.status(400).json({
                code: 400,
                message: 'URL 不能为空'
            })
        }

        const result = await fetchUrlInfo(url)

        res.json({
            code: 200,
            message: 'success',
            data: result
        })
    } catch (error) {
        // 解析失败时返回基本信息
        try {
            const urlObj = new URL(req.body.url)
            res.json({
                code: 200,
                message: 'partial',
                data: {
                    title: urlObj.hostname,
                    description: '',
                    favicon: `https://www.google.com/s2/favicons?domain=${urlObj.hostname}&sz=64`
                }
            })
        } catch {
            next(error)
        }
    }
}

// 批量解析
const batchParse = async (req, res, next) => {
    try {
        const { urls } = req.body

        if (!Array.isArray(urls)) {
            return res.status(400).json({
                code: 400,
                message: '参数格式错误'
            })
        }

        const results = await Promise.allSettled(
            urls.map(url => fetchUrlInfo(url))
        )

        const data = results.map((result, index) => ({
            url: urls[index],
            success: result.status === 'fulfilled',
            data: result.status === 'fulfilled' ? result.value : null
        }))

        res.json({
            code: 200,
            message: 'success',
            data
        })
    } catch (error) {
        next(error)
    }
}

// 获取 favicon
const getFavicon = async (req, res, next) => {
    try {
        const { url } = req.query

        if (!url) {
            return res.status(400).json({
                code: 400,
                message: 'URL 不能为空'
            })
        }

        const urlObj = new URL(url)
        const faviconUrl = await findFavicon(url, urlObj.origin)

        res.json({
            code: 200,
            message: 'success',
            data: { favicon: faviconUrl }
        })
    } catch (error) {
        next(error)
    }
}

// 辅助函数：获取网页信息
async function fetchUrlInfo(url) {
    const response = await axios.get(url, {
        timeout: 10000,
        headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8'
        },
        maxRedirects: 5
    })

    const $ = cheerio.load(response.data)
    const urlObj = new URL(url)

    // 获取标题
    let title = $('title').text().trim()
    if (!title) {
        title = $('meta[property="og:title"]').attr('content') || ''
    }
    if (!title) {
        title = $('meta[name="twitter:title"]').attr('content') || ''
    }
    if (!title) {
        title = urlObj.hostname
    }

    // 获取描述
    let description = $('meta[name="description"]').attr('content') || ''
    if (!description) {
        description = $('meta[property="og:description"]').attr('content') || ''
    }
    if (!description) {
        description = $('meta[name="twitter:description"]').attr('content') || ''
    }

    // 获取图标
    const favicon = await findFaviconFromHtml($, urlObj.origin)

    return {
        title: title.slice(0, 100),
        description: description.slice(0, 255),
        favicon
    }
}

// 从 HTML 中查找 favicon
async function findFaviconFromHtml($, origin) {
    // 尝试不同的 favicon 选择器
    const selectors = [
        'link[rel="icon"]',
        'link[rel="shortcut icon"]',
        'link[rel="apple-touch-icon"]',
        'link[rel="apple-touch-icon-precomposed"]'
    ]

    for (const selector of selectors) {
        const href = $(selector).attr('href')
        if (href) {
            // 处理相对路径
            if (href.startsWith('//')) {
                return 'https:' + href
            }
            if (href.startsWith('/')) {
                return origin + href
            }
            if (href.startsWith('http')) {
                return href
            }
            return origin + '/' + href
        }
    }

    // 尝试默认 favicon.ico
    try {
        const faviconUrl = origin + '/favicon.ico'
        await axios.head(faviconUrl, { timeout: 3000 })
        return faviconUrl
    } catch {
        // 使用 Google Favicon 服务作为后备
        const domain = new URL(origin).hostname
        return `https://www.google.com/s2/favicons?domain=${domain}&sz=64`
    }
}

// 查找 favicon
async function findFavicon(url, origin) {
    try {
        const response = await axios.get(url, {
            timeout: 5000,
            headers: { 'User-Agent': 'Mozilla/5.0' }
        })
        const $ = cheerio.load(response.data)
        return await findFaviconFromHtml($, origin)
    } catch {
        const domain = new URL(origin).hostname
        return `https://www.google.com/s2/favicons?domain=${domain}&sz=64`
    }
}

module.exports = {
    parseUrl,
    batchParse,
    getFavicon
}
