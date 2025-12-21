const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

// 获取所有笔记 (按时间倒序)
exports.getNotes = async (req, res, next) => {
    try {
        const notes = await prisma.note.findMany({
            orderBy: { updatedAt: 'desc' }
        })
        res.json({
            code: 200,
            data: notes,
            message: '获取成功'
        })
    } catch (error) {
        next(error)
    }
}

// 创建笔记
exports.createNote = async (req, res, next) => {
    try {
        const { content } = req.body
        if (!content) {
            return res.status(400).json({
                code: 400,
                message: '内容不能为空'
            })
        }

        const note = await prisma.note.create({
            data: { content }
        })

        res.json({
            code: 200,
            data: note,
            message: '创建成功'
        })
    } catch (error) {
        next(error)
    }
}

// 更新笔记
exports.updateNote = async (req, res, next) => {
    try {
        const { id } = req.params
        const { content } = req.body

        const note = await prisma.note.update({
            where: { id: parseInt(id) },
            data: { content }
        })

        res.json({
            code: 200,
            data: note,
            message: '更新成功'
        })
    } catch (error) {
        next(error)
    }
}

// 删除笔记
exports.deleteNote = async (req, res, next) => {
    try {
        const { id } = req.params
        await prisma.note.delete({
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
