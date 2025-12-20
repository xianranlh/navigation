const express = require('express')
const router = express.Router()
const auth = require('../middlewares/auth')

// 搜索链接（放在 /:id 之前）
router.get('/search', linkController.searchLinks)

// 获取所有链接
router.get('/', linkController.getLinks)

// 获取单个链接
router.get('/:id', linkController.getLinkById)

// 创建链接
router.post('/', auth, linkController.createLink)

// 更新链接
router.put('/:id', auth, linkController.updateLink)

// 删除链接
router.delete('/:id', auth, linkController.deleteLink)

// 记录点击 (不需要认证)
router.post('/:id/click', linkController.recordClick)

// 批量重排序
router.put('/reorder', auth, linkController.reorderLinks)

// 批量删除
router.post('/batch-delete', auth, linkController.batchDelete)

// 批量移动
router.post('/batch-move', auth, linkController.batchMove)

module.exports = router
