const errorHandler = (err, req, res, next) => {
    console.error('Error:', err)

    // Prisma 错误处理
    if (err.code === 'P2002') {
        return res.status(400).json({
            code: 400,
            message: '数据已存在，请勿重复创建'
        })
    }

    if (err.code === 'P2025') {
        return res.status(404).json({
            code: 404,
            message: '请求的资源不存在'
        })
    }

    // JWT 错误
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({
            code: 401,
            message: 'Token 无效'
        })
    }

    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
            code: 401,
            message: 'Token 已过期'
        })
    }

    // 默认错误
    const status = err.status || 500
    const message = err.message || '服务器内部错误'

    res.status(status).json({
        code: status,
        message
    })
}

module.exports = errorHandler
