# 个人导航页 | Personal Navigation Page

一个简洁、美观、响应式的个人导航页面项目，支持 Docker 部署。

## ✨ 特性

- 🎨 精美的渐变色设计
- 📱 完全响应式布局，支持移动端
- 🔍 实时搜索和过滤功能
- 🚀 基于 Nginx + Docker 快速部署
- ⚡ 轻量级，加载速度快
- 🎯 易于自定义和扩展

## 📦 快速开始

### 使用 Docker Compose（推荐）

1. 克隆项目
```bash
git clone https://github.com/xianranlh/navigation.git
cd navigation
```

2. 启动服务
```bash
docker-compose up -d
```

3. 访问导航页
在浏览器中打开 `http://localhost:8080`

### 使用 Docker

1. 构建镜像
```bash
docker build -t personal-navigation .
```

2. 运行容器
```bash
docker run -d -p 8080:80 --name navigation personal-navigation
```

3. 访问导航页
在浏览器中打开 `http://localhost:8080`

### 本地开发

直接使用浏览器打开 `index.html` 文件即可预览。

## 🛠️ 自定义配置

### 修改导航链接

编辑 `index.html` 文件，在对应的分类下添加或修改链接：

```html
<a href="https://example.com" target="_blank" class="link-card">
    <div class="icon">🔗</div>
    <div class="link-info">
        <h3>网站名称</h3>
        <p>网站描述</p>
    </div>
</a>
```

### 修改样式

编辑 `css/style.css` 文件中的 CSS 变量来自定义配色方案：

```css
:root {
    --primary-color: #4a90e2;
    --secondary-color: #f5f7fa;
    --text-color: #333;
    --text-light: #666;
}
```

### 修改搜索引擎

编辑 `js/script.js` 文件中的搜索引擎配置：

```javascript
const searchEngines = {
    google: 'https://www.google.com/search?q=',
    baidu: 'https://www.baidu.com/s?wd=',
    bing: 'https://www.bing.com/search?q='
};
```

## 📁 项目结构

```
navigation/
├── index.html          # 主页面
├── css/
│   └── style.css      # 样式文件
├── js/
│   └── script.js      # JavaScript 功能
├── nginx.conf         # Nginx 配置
├── Dockerfile         # Docker 镜像配置
├── docker-compose.yml # Docker Compose 配置
└── README.md          # 项目说明
```

## 🔧 Docker 命令

### 停止服务
```bash
docker-compose down
```

### 查看日志
```bash
docker-compose logs -f
```

### 重启服务
```bash
docker-compose restart
```

### 更新服务
```bash
docker-compose down
docker-compose up -d --build
```

## 🌐 端口配置

默认使用 8080 端口，如需修改，编辑 `docker-compose.yml` 文件：

```yaml
ports:
  - "你的端口:80"
```

## 📄 License

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题或建议，请通过 GitHub Issues 联系。
