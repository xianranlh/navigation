# 使用 Debian-slim 镜像，对 Prisma 和 OpenSSL 兼容性更好
FROM node:18-slim

# 安装 OpenSSL 和 CA 证书
RUN apt-get update -y && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 复制 package 文件
COPY package*.json ./
COPY prisma ./prisma/

# 安装依赖
RUN npm install --only=production

# 生成 Prisma Client
RUN npx prisma generate

# 复制源代码
COPY . .

# 确保二进制文件有执行权限
RUN chmod +x node_modules/.bin/*

EXPOSE 13001

# 启动命令：先执行数据库迁移，再启动服务
CMD ["sh", "-c", "npx prisma db push && node src/app.js"]
