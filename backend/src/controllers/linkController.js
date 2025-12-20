const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

const DEFAULT_USER_ID = 1

// 获取所有链接
const getLinks = async (req, res, next) => {
    try {
        const { categoryId } = req.query

        const where = { userId: DEFAULT_USER_ID }
        if (categoryId) {
            where.categoryId = parseInt(categoryId)
        }

        const links = await prisma.link.findMany({
            where,
            orderBy: { sortOrder: 'asc' }
        })

        res.json({
            code: 200,
            message: 'success',
            data: links
        })
    } catch (error) {
        next(error)
    }
}

// 获取单个链接
const getLinkById = async (req, res, next) => {
    try {
        const { id } = req.params

        const link = await prisma.link.findUnique({
            where: { id: parseInt(id) }
        })

        if (!link) {
            return res.status(404).json({
                code: 404,
                message: '链接不存在'
            })
        }

        res.json({
            code: 200,
            message: 'success',
            data: link
        })
    } catch (error) {
        next(error)
    }
}

// 创建链接
const createLink = async (req, res, next) => {
    try {
        const { title, url, description, icon, categoryId } = req.body

        if (!title || !url || !categoryId) {
            return res.status(400).json({
                code: 400,
                message: '标题、URL和分类ID不能为空'
            })
        }

        // 获取分类内最大排序号
        const maxOrder = await prisma.link.findFirst({
            where: { categoryId: parseInt(categoryId) },
            orderBy: { sortOrder: 'desc' },
            select: { sortOrder: true }
        })

        const link = await prisma.link.create({
            data: {
                title,
                url,
                description: description || '',
                icon: icon || '',
                categoryId: parseInt(categoryId),
                sortOrder: (maxOrder?.sortOrder || 0) + 1,
                userId: DEFAULT_USER_ID
            }
        })

        res.json({
            code: 200,
            message: '创建成功',
            data: link
        })
    } catch (error) {
        next(error)
    }
}

// 更新链接
const updateLink = async (req, res, next) => {
    try {
        const { id } = req.params
        const { title, url, description, icon, categoryId, sortOrder } = req.body

        const link = await prisma.link.update({
            where: { id: parseInt(id) },
            data: {
                ...(title !== undefined && { title }),
                ...(url !== undefined && { url }),
                ...(description !== undefined && { description }),
                ...(icon !== undefined && { icon }),
                ...(categoryId !== undefined && { categoryId: parseInt(categoryId) }),
                ...(sortOrder !== undefined && { sortOrder })
            }
        })

        res.json({
            code: 200,
            message: '更新成功',
            data: link
        })
    } catch (error) {
        next(error)
    }
}

// 删除链接
const deleteLink = async (req, res, next) => {
    try {
        const { id } = req.params

        await prisma.link.delete({
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

// 记录点击
const recordClick = async (req, res, next) => {
    try {
        const { id } = req.params

        await prisma.link.update({
            where: { id: parseInt(id) },
            data: { clickCount: { increment: 1 } }
        })

        res.json({
            code: 200,
            message: 'success'
        })
    } catch (error) {
        next(error)
    }
}

// 搜索链接
const searchLinks = async (req, res, next) => {
    try {
        const { q } = req.query

        if (!q) {
            return res.json({
                code: 200,
                message: 'success',
                data: []
            })
        }

        const links = await prisma.link.findMany({
            where: {
                userId: DEFAULT_USER_ID,
                OR: [
                    { title: { contains: q } },
                    { description: { contains: q } },
                    { url: { contains: q } }
                ]
            },
            include: {
                category: { select: { name: true } }
            },
            take: 20
        })

        res.json({
            code: 200,
            message: 'success',
            data: links.map(link => ({
                ...link,
                categoryName: link.category?.name
            }))
        })
    } catch (error) {
        next(error)
    }
}

// 批量重排序
const reorderLinks = async (req, res, next) => {
    try {
        const { categoryId, linkIds } = req.body

        if (!Array.isArray(linkIds)) {
            return res.status(400).json({
                code: 400,
                message: '参数格式错误'
            })
        }

        await Promise.all(
            linkIds.map((id, index) =>
                prisma.link.update({
                    where: { id },
                    data: {
                        sortOrder: index,
                        ...(categoryId && { categoryId: parseInt(categoryId) })
                    }
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

// 批量删除
const batchDelete = async (req, res, next) => {
    try {
        const { ids } = req.body

        if (!Array.isArray(ids)) {
            return res.status(400).json({
                code: 400,
                message: '参数格式错误'
            })
        }

        await prisma.link.deleteMany({
            where: { id: { in: ids } }
        })

        res.json({
            code: 200,
            message: `成功删除 ${ids.length} 个链接`
        })
    } catch (error) {
        next(error)
    }
}

// 批量移动
const batchMove = async (req, res, next) => {
    try {
        const { ids, categoryId } = req.body

        if (!Array.isArray(ids) || !categoryId) {
            return res.status(400).json({
                code: 400,
                message: '参数格式错误'
            })
        }

        await prisma.link.updateMany({
            where: { id: { in: ids } },
            data: { categoryId: parseInt(categoryId) }
        })

        res.json({
            code: 200,
            message: `成功移动 ${ids.length} 个链接`
        })
    } catch (error) {
        next(error)
    }
}

module.exports = {
    getLinks,
    getLinkById,
    createLink,
    updateLink,
    deleteLink,
    recordClick,
    searchLinks,
    reorderLinks,
    batchDelete,
    batchMove
}
