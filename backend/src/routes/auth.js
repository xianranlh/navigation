const express = require('express')
const router = express.Router()
const authController = require('../controllers/authController')
const auth = require('../middlewares/auth')

// 公开路由
router.post('/login', authController.login)

// 保护路由
router.get('/me', auth, authController.me)

module.exports = router
