const jwt = require('jsonwebtoken')
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

const auth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                code: 401,
                message: '未登录或 token 无效'
            })
        }

        const token = authHeader.split(' ')[1]
        const decoded = jwt.verify(token, process.env.JWT_SECRET)

        const user = await prisma.user.findUnique({
            where: { id: decoded.id }
        })

        if (!user) {
            return res.status(401).json({
                code: 401,
                message: '用户不存在'
            })
        }

        req.user = user
        next()
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                code: 401,
                message: '登录已过期'
            })
        }
        return res.status(401).json({
            code: 401,
            message: '认证失败'
        })
    }
}

module.exports = auth
