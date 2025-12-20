const multer = require('multer')
const path = require('path')
const fs = require('fs')
const crypto = require('crypto')

// 确保上传目录存在
const uploadDir = process.env.UPLOAD_DIR || './uploads'
const imagesDir = path.join(uploadDir, 'images')

if (!fs.existsSync(imagesDir)) {
    fs.mkdirSync(imagesDir, { recursive: true })
}

// 配置 multer 存储
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, imagesDir)
    },
    filename: (req, file, cb) => {
        // 生成唯一文件名
        const uniqueId = crypto.randomBytes(8).toString('hex')
        const ext = path.extname(file.originalname).toLowerCase()
        const filename = `${Date.now()}-${uniqueId}${ext}`
        cb(null, filename)
    }
})

// 文件过滤器
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml', 'image/x-icon']

    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true)
    } else {
        cb(new Error('只允许上传图片文件 (JPEG, PNG, GIF, WebP, SVG, ICO)'), false)
    }
}

// 创建 multer 实例
const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: parseInt(process.env.MAX_FILE_SIZE) || 100 * 1024 * 1024 // 默认 100MB
    }
})

// 上传单张图片
const uploadImage = [
    upload.single('image'),
    async (req, res, next) => {
        try {
            if (!req.file) {
                return res.status(400).json({
                    code: 400,
                    message: '请选择要上传的图片'
                })
            }

            // 生成访问 URL
            const imageUrl = `/uploads/images/${req.file.filename}`

            res.json({
                code: 200,
                message: '上传成功',
                data: {
                    filename: req.file.filename,
                    originalName: req.file.originalname,
                    size: req.file.size,
                    mimetype: req.file.mimetype,
                    url: imageUrl
                }
            })
        } catch (error) {
            next(error)
        }
    }
]

// 上传多张图片
const uploadImages = [
    upload.array('images', 10), // 最多 10 张
    async (req, res, next) => {
        try {
            if (!req.files || req.files.length === 0) {
                return res.status(400).json({
                    code: 400,
                    message: '请选择要上传的图片'
                })
            }

            const results = req.files.map(file => ({
                filename: file.filename,
                originalName: file.originalname,
                size: file.size,
                mimetype: file.mimetype,
                url: `/uploads/images/${file.filename}`
            }))

            res.json({
                code: 200,
                message: `成功上传 ${results.length} 张图片`,
                data: results
            })
        } catch (error) {
            next(error)
        }
    }
]

// 删除图片
const deleteImage = async (filename) => {
    const filePath = path.join(imagesDir, filename)
    if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath)
        return true
    }
    return false
}

module.exports = {
    uploadImage,
    uploadImages,
    deleteImage,
    imagesDir
}
