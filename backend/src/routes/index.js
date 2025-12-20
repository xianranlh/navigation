const express = require('express')
const router = express.Router()

const authRoutes = require('./auth')
const categoryRoutes = require('./category')
const linkRoutes = require('./link')
const parseRoutes = require('./parse')
const uploadRoutes = require('./upload')

router.use('/auth', authRoutes)
router.use('/categories', categoryRoutes)
router.use('/links', linkRoutes)
router.use('/parse', parseRoutes)
router.use('/upload', uploadRoutes)

// 根路由
router.get('/', (req, res) => {
    res.json({
        code: 200,
        message: '星穹导航 API v1',
        endpoints: {
            categories: '/api/v1/categories',
            links: '/api/v1/links',
            parse: '/api/v1/parse',
            upload: '/api/v1/upload'
        }
    })
})

module.exports = router
