const { PrismaClient } = require('@prisma/client')
const bcrypt = require('bcryptjs')

const prisma = new PrismaClient()

async function main() {
    console.log('🌱 开始填充数据...')

    // 创建默认用户
    const user = await prisma.user.upsert({
        where: { username: 'admin' },
        update: {},
        create: {
            username: 'admin',
            password: await bcrypt.hash('admin123', 10),
            email: 'admin@example.com',
            role: 'admin'
        }
    })

    console.log('✅ 用户创建成功:', user.username)

    // 创建示例分类
    const categories = [
        { name: '常用工具', icon: '🔧', description: '常用的开发和工作工具' },
        { name: '社交媒体', icon: '💬', description: '社交平台和通讯工具' },
        { name: '技术学习', icon: '📚', description: '技术文档和学习资源' },
        { name: '娱乐休闲', icon: '🎮', description: '游戏和娱乐网站' }
    ]

    for (let i = 0; i < categories.length; i++) {
        const cat = categories[i]
        await prisma.category.upsert({
            where: { id: i + 1 },
            update: {},
            create: {
                ...cat,
                sortOrder: i,
                userId: user.id
            }
        })
    }

    console.log('✅ 分类创建成功')

    // 创建示例链接
    const links = [
        // 常用工具
        { title: 'GitHub', url: 'https://github.com', description: '代码托管平台', icon: 'https://github.com/favicon.ico', categoryId: 1 },
        { title: 'ChatGPT', url: 'https://chat.openai.com', description: 'AI 对话助手', icon: '', categoryId: 1 },
        { title: 'Notion', url: 'https://notion.so', description: '笔记和协作工具', icon: '', categoryId: 1 },
        // 社交媒体
        { title: '微博', url: 'https://weibo.com', description: '微博社交平台', icon: '', categoryId: 2 },
        { title: 'Twitter', url: 'https://twitter.com', description: '全球社交平台', icon: '', categoryId: 2 },
        // 技术学习
        { title: 'MDN', url: 'https://developer.mozilla.org', description: 'Web 技术文档', icon: '', categoryId: 3 },
        { title: 'Vue.js', url: 'https://vuejs.org', description: 'Vue 官方文档', icon: '', categoryId: 3 },
        // 娱乐休闲
        { title: '崩坏：星穹铁道', url: 'https://sr.mihoyo.com', description: '米哈游回合制RPG', icon: '', categoryId: 4 },
        { title: 'Bilibili', url: 'https://bilibili.com', description: '视频分享平台', icon: '', categoryId: 4 }
    ]

    for (let i = 0; i < links.length; i++) {
        const link = links[i]
        await prisma.link.upsert({
            where: { id: i + 1 },
            update: {},
            create: {
                ...link,
                sortOrder: i,
                userId: user.id
            }
        })
    }

    console.log('✅ 链接创建成功')
    console.log('🎉 数据填充完成!')
}

main()
    .catch((e) => {
        console.error('❌ 填充失败:', e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
