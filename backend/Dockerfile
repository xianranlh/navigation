FROM node:18-alpine

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

EXPOSE 4000

# 启动命令：先执行数据库迁移，再启动服务
CMD ["sh", "-c", "npx prisma db push && node src/app.js"]
