const express = require('express')
const router = express.Router()
const uploadController = require('../controllers/uploadController')
const auth = require('../middlewares/auth')

// 上传图片
router.post('/image', auth, uploadController.uploadImage)

// 上传多张图片
router.post('/images', auth, uploadController.uploadImages)

// 获取图片（静态文件由 app.js 处理）

module.exports = router
