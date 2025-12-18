#!/bin/sh

# 确保 uploads 目录存在
mkdir -p /app/public/uploads

# 确保上传目录有写入权限
chmod -R 777 /app/public/uploads

# 启动应用
exec node server.js
