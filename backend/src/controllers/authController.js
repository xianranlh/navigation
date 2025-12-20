const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')

const prisma = new PrismaClient()

// 登录
exports.login = async (req, res, next) => {
    try {
        const { username, password } = req.body

        if (!username || !password) {
            return res.status(400).json({
                code: 400,
                message: '用户名和密码不能为空'
            })
        }

        // 查找用户
        const user = await prisma.user.findUnique({
            where: { username }
        })

        if (!user) {
            return res.status(401).json({
                code: 401,
                message: '用户名或密码错误'
            })
        }

        // 验证密码
        const isValid = await bcrypt.compare(password, user.password)
        if (!isValid) {
            return res.status(401).json({
                code: 401,
                message: '用户名或密码错误'
            })
        }

        // 生成 Token
        const token = jwt.sign(
            { id: user.id, username: user.username, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
        )

        res.json({
            code: 200,
            message: '登录成功',
            data: {
                token,
                user: {
                    id: user.id,
                    username: user.username,
                    role: user.role
                }
            }
        })
    } catch (error) {
        next(error)
    }
}

// 获取当前用户信息
exports.me = async (req, res, next) => {
    try {
        const user = req.user // 由 auth 中间件设置
        res.json({
            code: 200,
            data: {
                id: user.id,
                username: user.username,
                role: user.role,
                email: user.email
            }
        })
    } catch (error) {
        next(error)
    }
}
