const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

// 默认用户ID（单用户模式）
const DEFAULT_USER_ID = 1

// 获取所有分类
const getCategories = async (req, res, next) => {
    try {
        const { includeLinks } = req.query

        const categories = await prisma.category.findMany({
            where: { userId: DEFAULT_USER_ID },
            include: {
                links: includeLinks === 'true' ? {
                    orderBy: { sortOrder: 'asc' }
                } : false
            },
            orderBy: { sortOrder: 'asc' }
        })

        res.json({
            code: 200,
            message: 'success',
            data: categories
        })
    } catch (error) {
        next(error)
    }
}

// 获取单个分类
const getCategoryById = async (req, res, next) => {
    try {
        const { id } = req.params

        const category = await prisma.category.findUnique({
            where: { id: parseInt(id) },
            include: { links: { orderBy: { sortOrder: 'asc' } } }
        })

        if (!category) {
            return res.status(404).json({
                code: 404,
                message: '分类不存在'
            })
        }

        res.json({
            code: 200,
            message: 'success',
            data: category
        })
    } catch (error) {
        next(error)
    }
}

// 创建分类
const createCategory = async (req, res, next) => {
    try {
        const { name, icon, description } = req.body

        if (!name) {
            return res.status(400).json({
                code: 400,
                message: '分类名称不能为空'
            })
        }

        // 获取最大排序号
        const maxOrder = await prisma.category.findFirst({
            where: { userId: DEFAULT_USER_ID },
            orderBy: { sortOrder: 'desc' },
            select: { sortOrder: true }
        })

        const category = await prisma.category.create({
            data: {
                name,
                icon: icon || '',
                description: description || '',
                sortOrder: (maxOrder?.sortOrder || 0) + 1,
                userId: DEFAULT_USER_ID
            }
        })

        res.json({
            code: 200,
            message: '创建成功',
            data: category
        })
    } catch (error) {
        next(error)
    }
}

// 更新分类
const updateCategory = async (req, res, next) => {
    try {
        const { id } = req.params
        const { name, icon, description, sortOrder } = req.body

        const category = await prisma.category.update({
            where: { id: parseInt(id) },
            data: {
                ...(name !== undefined && { name }),
                ...(icon !== undefined && { icon }),
                ...(description !== undefined && { description }),
                ...(sortOrder !== undefined && { sortOrder })
            }
        })

        res.json({
            code: 200,
            message: '更新成功',
            data: category
        })
    } catch (error) {
        next(error)
    }
}

// 删除分类
const deleteCategory = async (req, res, next) => {
    try {
        const { id } = req.params

        await prisma.category.delete({
            where: { id: parseInt(id) }
        })

        res.json({
            code: 200,
            message: '删除成功'
        })
    } catch (error) {
        next(error)
    }
}

// 批量重排序
const reorderCategories = async (req, res, next) => {
    try {
        const { categoryIds } = req.body

        if (!Array.isArray(categoryIds)) {
            return res.status(400).json({
                code: 400,
                message: '参数格式错误'
            })
        }

        // 批量更新排序
        await Promise.all(
            categoryIds.map((id, index) =>
                prisma.category.update({
                    where: { id },
                    data: { sortOrder: index }
                })
            )
        )

        res.json({
            code: 200,
            message: '排序更新成功'
        })
    } catch (error) {
        next(error)
    }
}

module.exports = {
    getCategories,
    getCategoryById,
    createCategory,
    updateCategory,
    deleteCategory,
    reorderCategories
}
