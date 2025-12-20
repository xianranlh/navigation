#!/bin/sh

# 调试：显示 DATABASE_URL
echo "DEBUG: DATABASE_URL = $DATABASE_URL"

# 检查是否使用 MySQL（通过 DATABASE_URL 判断）
if echo "$DATABASE_URL" | grep -q "mysql://"; then
  echo "使用 MySQL 数据库"
  echo "MySQL 连接: $DATABASE_URL"
else
  # SQLite 模式（向后兼容）
  echo "使用 SQLite 数据库"
  if [ ! -f /app/data/dev.db ]; then
    echo "数据库不存在，正在初始化..."
    cp /app/prisma/dev.db.init /app/data/dev.db 2>/dev/null || touch /app/data/dev.db
    echo "数据库初始化完成"
  fi
  chmod 666 /app/data/dev.db 2>/dev/null || true
fi

# 确保 uploads 目录存在 (使用 data 卷进行统一存储)
mkdir -p /app/data/uploads

# 将 public/uploads 链接到 data/uploads
if [ ! -L /app/public/uploads ]; then
  # 如果容器构建时存在 public/uploads 且不为空，尝试迁移文件 (防止覆盖现有数据)
  if [ -d /app/public/uploads ]; then
    cp -rn /app/public/uploads/* /app/data/uploads/ 2>/dev/null || true
    rm -rf /app/public/uploads
  fi
  ln -s /app/data/uploads /app/public/uploads
fi

# 确保数据目录和上传目录有写入权限
chmod -R 777 /app/data
chmod -R 777 /app/public/uploads

# 启动应用
exec node server.js
