const express = require('express')
const router = express.Router()
const categoryController = require('../controllers/categoryController')

// 获取所有分类（可包含链接）
router.get('/', categoryController.getCategories)

// 获取单个分类
router.get('/:id', categoryController.getCategoryById)

// 创建分类
router.post('/', categoryController.createCategory)

// 更新分类
router.put('/:id', categoryController.updateCategory)

// 删除分类
router.delete('/:id', categoryController.deleteCategory)

// 批量重排序
router.put('/reorder', categoryController.reorderCategories)

module.exports = router
