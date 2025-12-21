const express = require('express')
const router = express.Router()
const noteController = require('../controllers/noteController')
const auth = require('../middlewares/auth')

// 获取所有笔记 (公开或需登录? 这里设为公开以便查看，或统一保护)
// 用户要求"笔记"功能，通常是私有的，所以增删改查最好都保护
// 但如果只是展示给访客看，get可以公开。
// 鉴于之前逻辑是Admin编辑，访客查看，我们暂时允许访客查看笔记? 
// 或者笔记是管理员的备忘录? 便签通常是个人用的。
// 既然是"便签"，且目前是单用户系统，建议增删改查都加 auth。
// 但为了方便演示，Get 可以不加 Auth? 不，默认全加 Auth 更安全。
// 不过前端 NoteWidget 如果放在首页，访客也能看到? 
// 让我们假设这个 Note 功能是类似"公告"或者"管理员的便签"。
// 如果是"管理员的便签"，那么普通用户应该看不到? 
// 为了简单起见，且符合"个人导航页"属性，GET 公开，CUD 需要权限。

router.get('/', noteController.getNotes)
router.post('/', auth, noteController.createNote)
router.put('/:id', auth, noteController.updateNote)
router.delete('/:id', auth, noteController.deleteNote)

module.exports = router
