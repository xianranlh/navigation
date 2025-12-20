# 个人导航页项目指导书

## 项目概述

### 项目背景
个人导航页是一个用于管理和快速访问常用网站链接的工具。用户可以自定义分类、添加/编辑/删除链接，并通过美观的界面快速跳转到目标网站。

### 技术栈
| 层级 | 技术选型 | 版本建议 |
|------|----------|----------|
| 前端框架 | Vue 3 | 3.4+ |
| 构建工具 | Vite | 5.0+ |
| UI框架 | Element Plus | 2.4+ |
| 状态管理 | Pinia | 2.1+ |
| 路由 | Vue Router | 4.2+ |
| HTTP客户端 | Axios | 1.6+ |
| 后端框架 | Node.js + Express | 18+ / 4.18+ |
| 数据库 | MySQL | 8.0+ |
| ORM | Prisma | 5.0+ |
| 容器化 | Docker + Docker Compose | 24+ |

---

## 一、项目结构设计

### 1.1 目录结构

```
navigation/
├── frontend/                    # 前端项目
│   ├── public/
│   │   └── favicon.ico
│   ├── src/
│   │   ├── api/                 # API 接口封装
│   │   │   ├── index.js
│   │   │   ├── category.js
│   │   │   └── link.js
│   │   ├── assets/              # 静态资源
│   │   │   ├── images/
│   │   │   └── styles/
│   │   │       ├── variables.css
│   │   │       └── global.css
│   │   ├── components/          # 公共组件
│   │   │   ├── Header.vue
│   │   │   ├── Sidebar.vue
│   │   │   ├── SearchBar.vue
│   │   │   ├── LinkCard.vue
│   │   │   └── CategoryCard.vue
│   │   ├── views/               # 页面视图
│   │   │   ├── Home.vue
│   │   │   ├── Admin.vue
│   │   │   └── Login.vue
│   │   ├── stores/              # Pinia 状态管理
│   │   │   ├── index.js
│   │   │   ├── category.js
│   │   │   └── user.js
│   │   ├── router/              # 路由配置
│   │   │   └── index.js
│   │   ├── utils/               # 工具函数
│   │   │   ├── request.js
│   │   │   └── storage.js
│   │   ├── App.vue
│   │   └── main.js
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
├── backend/                     # 后端项目
│   ├── prisma/
│   │   ├── schema.prisma        # 数据库模型定义
│   │   └── migrations/          # 数据库迁移文件
│   ├── src/
│   │   ├── controllers/         # 控制器
│   │   │   ├── categoryController.js
│   │   │   ├── linkController.js
│   │   │   └── userController.js
│   │   ├── middlewares/         # 中间件
│   │   │   ├── auth.js
│   │   │   └── errorHandler.js
│   │   ├── routes/              # 路由定义
│   │   │   ├── index.js
│   │   │   ├── category.js
│   │   │   ├── link.js
│   │   │   └── user.js
│   │   ├── services/            # 业务逻辑层
│   │   │   ├── categoryService.js
│   │   │   ├── linkService.js
│   │   │   └── userService.js
│   │   ├── utils/               # 工具函数
│   │   │   └── jwt.js
│   │   └── app.js               # 应用入口
│   ├── .env                     # 环境变量
│   └── package.json
│
├── docker-compose.yml           # Docker 编排配置
├── Dockerfile.frontend          # 前端 Docker 配置
├── Dockerfile.backend           # 后端 Docker 配置
└── README.md
```

---

## 二、数据库设计

### 2.1 ER 图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   users     │       │  categories │       │    links    │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │       │ id (PK)     │
│ username    │       │ name        │       │ title       │
│ password    │       │ icon        │       │ url         │
│ email       │       │ sort_order  │       │ description │
│ avatar      │       │ user_id(FK) │◄──────│ icon        │
│ created_at  │       │ created_at  │       │ category_id │
│ updated_at  │       │ updated_at  │       │ sort_order  │
└──────┬──────┘       └──────┬──────┘       │ user_id(FK) │
       │                     │              │ created_at  │
       │     1:N             │    1:N       │ updated_at  │
       └─────────────────────┴──────────────┴─────────────┘
```

### 2.2 数据表结构

#### users 表（用户表）

```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码(加密存储)',
    email VARCHAR(100) COMMENT '邮箱',
    avatar VARCHAR(255) COMMENT '头像URL',
    role ENUM('admin', 'user') DEFAULT 'user' COMMENT '用户角色',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

#### categories 表（分类表）

```sql
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    icon VARCHAR(100) COMMENT '分类图标',
    description VARCHAR(255) COMMENT '分类描述',
    sort_order INT DEFAULT 0 COMMENT '排序顺序',
    is_public TINYINT(1) DEFAULT 1 COMMENT '是否公开',
    user_id INT NOT NULL COMMENT '所属用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_sort_order (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类表';
```

#### links 表（链接表）

```sql
CREATE TABLE links (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL COMMENT '链接标题',
    url VARCHAR(500) NOT NULL COMMENT '链接URL',
    description VARCHAR(255) COMMENT '链接描述',
    icon VARCHAR(255) COMMENT '链接图标',
    category_id INT NOT NULL COMMENT '所属分类ID',
    sort_order INT DEFAULT 0 COMMENT '排序顺序',
    click_count INT DEFAULT 0 COMMENT '点击次数',
    is_public TINYINT(1) DEFAULT 1 COMMENT '是否公开',
    user_id INT NOT NULL COMMENT '所属用户ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_category_id (category_id),
    INDEX idx_user_id (user_id),
    INDEX idx_click_count (click_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='链接表';
```

### 2.3 Prisma Schema 定义

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int        @id @default(autoincrement())
  username  String     @unique @db.VarChar(50)
  password  String     @db.VarChar(255)
  email     String?    @db.VarChar(100)
  avatar    String?    @db.VarChar(255)
  role      Role       @default(user)
  createdAt DateTime   @default(now()) @map("created_at")
  updatedAt DateTime   @updatedAt @map("updated_at")
  
  categories Category[]
  links      Link[]
  
  @@map("users")
}

model Category {
  id          Int      @id @default(autoincrement())
  name        String   @db.VarChar(50)
  icon        String?  @db.VarChar(100)
  description String?  @db.VarChar(255)
  sortOrder   Int      @default(0) @map("sort_order")
  isPublic    Boolean  @default(true) @map("is_public")
  userId      Int      @map("user_id")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  user  User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  links Link[]
  
  @@index([userId])
  @@index([sortOrder])
  @@map("categories")
}

model Link {
  id          Int      @id @default(autoincrement())
  title       String   @db.VarChar(100)
  url         String   @db.VarChar(500)
  description String?  @db.VarChar(255)
  icon        String?  @db.VarChar(255)
  categoryId  Int      @map("category_id")
  sortOrder   Int      @default(0) @map("sort_order")
  clickCount  Int      @default(0) @map("click_count")
  isPublic    Boolean  @default(true) @map("is_public")
  userId      Int      @map("user_id")
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  category Category @relation(fields: [categoryId], references: [id], onDelete: Cascade)
  user     User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([categoryId])
  @@index([userId])
  @@index([clickCount])
  @@map("links")
}

enum Role {
  admin
  user
}
```

---

## 三、API 接口设计

### 3.1 接口规范

- **基础路径**: `/api/v1`
- **请求格式**: JSON
- **认证方式**: JWT Token (Bearer Token)
- **响应格式**:

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

### 3.2 接口列表

#### 用户模块

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| POST | /auth/register | 用户注册 | 公开 |
| POST | /auth/login | 用户登录 | 公开 |
| GET | /users/profile | 获取当前用户信息 | 登录 |
| PUT | /users/profile | 更新用户信息 | 登录 |
| PUT | /users/password | 修改密码 | 登录 |

#### 分类模块

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| GET | /categories | 获取分类列表 | 公开 |
| GET | /categories/:id | 获取分类详情 | 公开 |
| POST | /categories | 创建分类 | 登录 |
| PUT | /categories/:id | 更新分类 | 登录 |
| DELETE | /categories/:id | 删除分类 | 登录 |
| PUT | /categories/sort | 批量排序 | 登录 |

#### 链接模块

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| GET | /links | 获取链接列表 | 公开 |
| GET | /links/:id | 获取链接详情 | 公开 |
| POST | /links | 创建链接 | 登录 |
| PUT | /links/:id | 更新链接 | 登录 |
| DELETE | /links/:id | 删除链接 | 登录 |
| POST | /links/:id/click | 记录点击 | 公开 |
| GET | /links/search | 搜索链接 | 公开 |

### 3.3 接口详细定义

#### 用户登录

```
POST /api/v1/auth/login

Request:
{
  "username": "admin",
  "password": "123456"
}

Response:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "avatar": "/avatars/default.png",
      "role": "admin"
    }
  }
}
```

#### 获取分类列表（含链接）

```
GET /api/v1/categories?includeLinks=true

Response:
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "常用工具",
      "icon": "tool",
      "sortOrder": 1,
      "links": [
        {
          "id": 1,
          "title": "GitHub",
          "url": "https://github.com",
          "description": "代码托管平台",
          "icon": "https://github.com/favicon.ico",
          "clickCount": 100
        }
      ]
    }
  ]
}
```

#### 创建链接

```
POST /api/v1/links
Authorization: Bearer <token>

Request:
{
  "title": "GitHub",
  "url": "https://github.com",
  "description": "代码托管平台",
  "icon": "",
  "categoryId": 1
}

Response:
{
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": 1,
    "title": "GitHub",
    "url": "https://github.com",
    "description": "代码托管平台",
    "icon": "https://github.com/favicon.ico",
    "categoryId": 1,
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## 四、前端开发指南

### 4.1 项目初始化

```bash
# 创建 Vue 3 项目
npm create vite@latest frontend -- --template vue

# 进入项目目录
cd frontend

# 安装依赖
npm install

# 安装额外依赖
npm install vue-router@4 pinia axios element-plus @element-plus/icons-vue
npm install -D sass unplugin-vue-components unplugin-auto-import
```

### 4.2 Vite 配置

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import path from 'path'

export default defineConfig({
  plugins: [
    vue(),
    AutoImport({
      resolvers: [ElementPlusResolver()],
      imports: ['vue', 'vue-router', 'pinia']
    }),
    Components({
      resolvers: [ElementPlusResolver()]
    })
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src')
    }
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true
      }
    }
  }
})
```

### 4.3 核心组件实现

#### App.vue

```vue
<template>
  <div class="app-container" :class="{ 'dark-mode': isDarkMode }">
    <Header @toggle-theme="toggleTheme" />
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { ref, provide } from 'vue'
import Header from '@/components/Header.vue'

const isDarkMode = ref(false)

const toggleTheme = () => {
  isDarkMode.value = !isDarkMode.value
  document.documentElement.setAttribute('data-theme', isDarkMode.value ? 'dark' : 'light')
}

provide('isDarkMode', isDarkMode)
</script>

<style>
.app-container {
  min-height: 100vh;
  background: var(--bg-primary);
  transition: background 0.3s ease;
}

.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}
</style>
```

#### Home.vue（首页视图）

```vue
<template>
  <div class="home">
    <!-- 搜索栏 -->
    <SearchBar v-model="searchQuery" @search="handleSearch" />
    
    <!-- 分类和链接展示 -->
    <div class="categories-container">
      <template v-for="category in filteredCategories" :key="category.id">
        <CategoryCard :category="category">
          <div class="links-grid">
            <LinkCard 
              v-for="link in category.links" 
              :key="link.id" 
              :link="link"
              @click="handleLinkClick(link)"
            />
          </div>
        </CategoryCard>
      </template>
    </div>
    
    <!-- 空状态 -->
    <el-empty v-if="!filteredCategories.length" description="暂无数据" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCategoryStore } from '@/stores/category'
import SearchBar from '@/components/SearchBar.vue'
import CategoryCard from '@/components/CategoryCard.vue'
import LinkCard from '@/components/LinkCard.vue'
import { recordClick } from '@/api/link'

const categoryStore = useCategoryStore()
const searchQuery = ref('')

const filteredCategories = computed(() => {
  if (!searchQuery.value) return categoryStore.categories
  
  return categoryStore.categories
    .map(cat => ({
      ...cat,
      links: cat.links.filter(link => 
        link.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        link.description?.toLowerCase().includes(searchQuery.value.toLowerCase())
      )
    }))
    .filter(cat => cat.links.length > 0)
})

const handleSearch = (query) => {
  searchQuery.value = query
}

const handleLinkClick = async (link) => {
  await recordClick(link.id)
  window.open(link.url, '_blank')
}

onMounted(() => {
  categoryStore.fetchCategories()
})
</script>

<style scoped>
.home {
  padding: 20px 0;
}

.categories-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.links-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
}
</style>
```

#### LinkCard.vue（链接卡片组件）

```vue
<template>
  <div class="link-card" @click="$emit('click')">
    <div class="link-icon">
      <img v-if="link.icon" :src="link.icon" :alt="link.title" @error="handleIconError" />
      <el-icon v-else><Link /></el-icon>
    </div>
    <div class="link-info">
      <h4 class="link-title">{{ link.title }}</h4>
      <p class="link-desc">{{ link.description || '暂无描述' }}</p>
    </div>
  </div>
</template>

<script setup>
import { Link } from '@element-plus/icons-vue'

defineProps({
  link: {
    type: Object,
    required: true
  }
})

defineEmits(['click'])

const handleIconError = (e) => {
  e.target.style.display = 'none'
}
</script>

<style scoped>
.link-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: var(--card-bg);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid var(--border-color);
}

.link-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.link-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--icon-bg);
  border-radius: 10px;
  flex-shrink: 0;
}

.link-icon img {
  width: 24px;
  height: 24px;
  object-fit: contain;
}

.link-info {
  flex: 1;
  min-width: 0;
}

.link-title {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.link-desc {
  margin: 0;
  font-size: 12px;
  color: var(--text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
```

### 4.4 状态管理 (Pinia)

```javascript
// stores/category.js
import { defineStore } from 'pinia'
import { getCategories, createCategory, updateCategory, deleteCategory } from '@/api/category'

export const useCategoryStore = defineStore('category', {
  state: () => ({
    categories: [],
    loading: false,
    error: null
  }),
  
  getters: {
    getCategoryById: (state) => (id) => {
      return state.categories.find(cat => cat.id === id)
    },
    
    totalLinks: (state) => {
      return state.categories.reduce((sum, cat) => sum + (cat.links?.length || 0), 0)
    }
  },
  
  actions: {
    async fetchCategories() {
      this.loading = true
      try {
        const res = await getCategories({ includeLinks: true })
        this.categories = res.data
      } catch (error) {
        this.error = error.message
      } finally {
        this.loading = false
      }
    },
    
    async addCategory(data) {
      const res = await createCategory(data)
      this.categories.push(res.data)
      return res.data
    },
    
    async editCategory(id, data) {
      const res = await updateCategory(id, data)
      const index = this.categories.findIndex(cat => cat.id === id)
      if (index !== -1) {
        this.categories[index] = { ...this.categories[index], ...res.data }
      }
      return res.data
    },
    
    async removeCategory(id) {
      await deleteCategory(id)
      this.categories = this.categories.filter(cat => cat.id !== id)
    }
  }
})
```

### 4.5 API 封装

```javascript
// api/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'

const request = axios.create({
  baseURL: '/api/v1',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message))
    }
    return res
  },
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    ElMessage.error(error.response?.data?.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
```

```javascript
// api/category.js
import request from './request'

export const getCategories = (params) => request.get('/categories', { params })

export const getCategoryById = (id) => request.get(`/categories/${id}`)

export const createCategory = (data) => request.post('/categories', data)

export const updateCategory = (id, data) => request.put(`/categories/${id}`, data)

export const deleteCategory = (id) => request.delete(`/categories/${id}`)

export const sortCategories = (data) => request.put('/categories/sort', data)
```

---

## 五、后端开发指南

### 5.1 项目初始化

```bash
# 创建后端项目
mkdir backend && cd backend
npm init -y

# 安装依赖
npm install express cors helmet morgan dotenv bcryptjs jsonwebtoken
npm install @prisma/client
npm install -D prisma nodemon

# 初始化 Prisma
npx prisma init
```

### 5.2 Express 应用入口

```javascript
// src/app.js
const express = require('express')
const cors = require('cors')
const helmet = require('helmet')
const morgan = require('morgan')
require('dotenv').config()

const routes = require('./routes')
const errorHandler = require('./middlewares/errorHandler')

const app = express()

// 中间件
app.use(helmet())
app.use(cors())
app.use(morgan('dev'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// 路由
app.use('/api/v1', routes)

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// 错误处理
app.use(errorHandler)

const PORT = process.env.PORT || 4000

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})

module.exports = app
```

### 5.3 控制器实现

```javascript
// src/controllers/categoryController.js
const categoryService = require('../services/categoryService')

const getCategories = async (req, res, next) => {
  try {
    const { includeLinks } = req.query
    const userId = req.user?.id
    const categories = await categoryService.findAll({
      includeLinks: includeLinks === 'true',
      userId
    })
    res.json({ code: 200, message: 'success', data: categories })
  } catch (error) {
    next(error)
  }
}

const getCategoryById = async (req, res, next) => {
  try {
    const { id } = req.params
    const category = await categoryService.findById(parseInt(id))
    if (!category) {
      return res.status(404).json({ code: 404, message: '分类不存在' })
    }
    res.json({ code: 200, message: 'success', data: category })
  } catch (error) {
    next(error)
  }
}

const createCategory = async (req, res, next) => {
  try {
    const data = { ...req.body, userId: req.user.id }
    const category = await categoryService.create(data)
    res.json({ code: 200, message: '创建成功', data: category })
  } catch (error) {
    next(error)
  }
}

const updateCategory = async (req, res, next) => {
  try {
    const { id } = req.params
    const category = await categoryService.update(parseInt(id), req.body)
    res.json({ code: 200, message: '更新成功', data: category })
  } catch (error) {
    next(error)
  }
}

const deleteCategory = async (req, res, next) => {
  try {
    const { id } = req.params
    await categoryService.remove(parseInt(id))
    res.json({ code: 200, message: '删除成功' })
  } catch (error) {
    next(error)
  }
}

module.exports = {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory
}
```

### 5.4 服务层实现

```javascript
// src/services/categoryService.js
const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

const findAll = async ({ includeLinks = false, userId }) => {
  const where = userId ? { userId } : { isPublic: true }
  
  return prisma.category.findMany({
    where,
    include: {
      links: includeLinks ? {
        where: userId ? {} : { isPublic: true },
        orderBy: { sortOrder: 'asc' }
      } : false
    },
    orderBy: { sortOrder: 'asc' }
  })
}

const findById = async (id) => {
  return prisma.category.findUnique({
    where: { id },
    include: { links: true }
  })
}

const create = async (data) => {
  return prisma.category.create({ data })
}

const update = async (id, data) => {
  return prisma.category.update({
    where: { id },
    data
  })
}

const remove = async (id) => {
  return prisma.category.delete({ where: { id } })
}

module.exports = {
  findAll,
  findById,
  create,
  update,
  remove
}
```

### 5.5 认证中间件

```javascript
// src/middlewares/auth.js
const jwt = require('jsonwebtoken')

const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ code: 401, message: '未授权访问' })
  }
  
  const token = authHeader.split(' ')[1]
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    req.user = decoded
    next()
  } catch (error) {
    return res.status(401).json({ code: 401, message: 'Token 无效或已过期' })
  }
}

const optionalAuth = (req, res, next) => {
  const authHeader = req.headers.authorization
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1]
    try {
      req.user = jwt.verify(token, process.env.JWT_SECRET)
    } catch (error) {
      // Token 无效时不阻止请求，只是不设置 user
    }
  }
  next()
}

module.exports = { authenticate, optionalAuth }
```

---

## 六、Docker 部署配置

### 6.1 docker-compose.yml

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: nav-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-root123}
      MYSQL_DATABASE: ${MYSQL_DATABASE:-navigation}
      MYSQL_USER: ${MYSQL_USER:-navuser}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-navpass123}
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - nav-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: nav-backend
    restart: unless-stopped
    environment:
      DATABASE_URL: mysql://${MYSQL_USER:-navuser}:${MYSQL_PASSWORD:-navpass123}@mysql:3306/${MYSQL_DATABASE:-navigation}
      JWT_SECRET: ${JWT_SECRET:-your-super-secret-key}
      PORT: 4000
    ports:
      - "4000:4000"
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - nav-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: nav-frontend
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - nav-network

networks:
  nav-network:
    driver: bridge

volumes:
  mysql_data:
```

### 6.2 后端 Dockerfile

```dockerfile
# backend/Dockerfile
FROM node:18-alpine

WORKDIR /app

# 复制 package 文件
COPY package*.json ./
COPY prisma ./prisma/

# 安装依赖
RUN npm ci --only=production

# 生成 Prisma Client
RUN npx prisma generate

# 复制源代码
COPY . .

EXPOSE 4000

# 启动命令
CMD ["sh", "-c", "npx prisma migrate deploy && node src/app.js"]
```

### 6.3 前端 Dockerfile

```dockerfile
# frontend/Dockerfile
FROM node:18-alpine as builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# 生产环境
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### 6.4 Nginx 配置

```nginx
# frontend/nginx.conf
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1000;
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API 代理
    location /api {
        proxy_pass http://backend:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }
    
    # SPA 路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 七、开发流程

### 7.1 本地开发环境搭建

```bash
# 1. 克隆项目
git clone <repository-url>
cd navigation

# 2. 启动 MySQL 容器
docker-compose up -d mysql

# 3. 后端设置
cd backend
cp .env.example .env
# 编辑 .env 文件配置数据库连接
npm install
npx prisma migrate dev
npm run dev

# 4. 前端设置（新终端）
cd frontend
npm install
npm run dev
```

### 7.2 环境变量配置

```bash
# backend/.env
DATABASE_URL="mysql://navuser:navpass123@localhost:3306/navigation"
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"
PORT=4000

# frontend/.env
VITE_API_BASE_URL=/api/v1
```

### 7.3 数据库迁移

```bash
# 创建迁移
npx prisma migrate dev --name init

# 应用迁移
npx prisma migrate deploy

# 重置数据库
npx prisma migrate reset

# 查看数据库
npx prisma studio
```

---

## 八、功能特性清单

### 8.1 核心功能

- [x] 用户认证（注册/登录/登出）
- [x] 分类管理（增删改查/排序）
- [x] 链接管理（增删改查/排序）
- [x] 全局搜索
- [x] 响应式设计
- [x] 暗色/亮色主题切换

### 8.2 扩展功能

- [ ] 链接图标自动抓取
- [ ] 拖拽排序
- [ ] 数据导入/导出
- [ ] 多用户支持
- [ ] 链接健康检查
- [ ] 访问统计仪表盘
- [ ] 标签系统
- [ ] 收藏夹功能

---

## 九、安全注意事项

> [!IMPORTANT]
> 以下安全措施必须在生产环境中实施

1. **密码加密**: 使用 bcrypt 对用户密码进行哈希存储
2. **JWT 配置**: 设置合理的过期时间，使用强密钥
3. **输入验证**: 对所有用户输入进行验证和清洗
4. **SQL 注入防护**: Prisma ORM 已内置防护
5. **XSS 防护**: 对输出内容进行转义
6. **CORS 配置**: 生产环境限制允许的域名
7. **HTTPS**: 生产环境必须使用 HTTPS
8. **Rate Limiting**: 添加请求频率限制

---

## 十、性能优化建议

1. **前端优化**
   - 路由懒加载
   - 图片懒加载
   - 静态资源 CDN
   - 组件按需引入

2. **后端优化**
   - 数据库索引优化
   - 查询缓存（Redis）
   - 接口响应压缩
   - 连接池配置

3. **部署优化**
   - Nginx 静态资源缓存
   - Gzip 压缩
   - HTTP/2 支持
   - 健康检查与自动重启

---

## 附录

### A. 常用命令速查

```bash
# Docker 相关
docker-compose up -d          # 启动所有服务
docker-compose down           # 停止所有服务
docker-compose logs -f        # 查看日志
docker-compose restart        # 重启服务

# Prisma 相关
npx prisma studio             # 打开数据库管理界面
npx prisma db push            # 同步数据库结构
npx prisma generate           # 生成客户端

# 开发相关
npm run dev                   # 启动开发服务器
npm run build                 # 构建生产版本
npm run lint                  # 代码检查
```

### B. 参考资源

- [Vue 3 官方文档](https://vuejs.org/)
- [Element Plus 组件库](https://element-plus.org/)
- [Prisma 文档](https://www.prisma.io/docs)
- [Express 文档](https://expressjs.com/)
- [Docker 文档](https://docs.docker.com/)
