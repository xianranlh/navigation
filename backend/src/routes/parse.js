const express = require('express')
const router = express.Router()
const parseController = require('../controllers/parseController')

// 解析 URL
router.post('/url', parseController.parseUrl)

// 批量解析
router.post('/batch', parseController.batchParse)

// 获取 favicon
router.get('/favicon', parseController.getFavicon)

module.exports = router
