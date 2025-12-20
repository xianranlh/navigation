const express = require('express')
const cors = require('cors')
const helmet = require('helmet')
const morgan = require('morgan')
const path = require('path')
require('dotenv').config()

const routes = require('./routes')
const errorHandler = require('./middlewares/errorHandler')

const app = express()

// 中间件
app.use(helmet({
    crossOriginResourcePolicy: { policy: "cross-origin" }
}))
app.use(cors())
app.use(morgan('dev'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// 静态文件服务 - 上传的图片
const uploadDir = process.env.UPLOAD_DIR || './uploads'
app.use('/uploads', express.static(path.resolve(uploadDir)))

// API 路由
app.use('/api/v1', routes)

// 健康检查
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: '星穹导航 API'
    })
})

// 错误处理
app.use(errorHandler)

const PORT = process.env.PORT || 4000

app.listen(PORT, () => {
    console.log(`🚀 星穹导航服务运行在端口 ${PORT}`)
    console.log(`📡 API: http://localhost:${PORT}/api/v1`)
})

module.exports = app
