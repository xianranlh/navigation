const express = require('express')
const router = express.Router()
const linkController = require('../controllers/linkController')

// 搜索链接（放在 /:id 之前）
router.get('/search', linkController.searchLinks)

// 获取所有链接
router.get('/', linkController.getLinks)

// 获取单个链接
router.get('/:id', linkController.getLinkById)

// 创建链接
router.post('/', linkController.createLink)

// 更新链接
router.put('/:id', linkController.updateLink)

// 删除链接
router.delete('/:id', linkController.deleteLink)

// 记录点击
router.post('/:id/click', linkController.recordClick)

// 批量重排序
router.put('/reorder', linkController.reorderLinks)

// 批量删除
router.post('/batch-delete', linkController.batchDelete)

// 批量移动
router.post('/batch-move', linkController.batchMove)

module.exports = router
