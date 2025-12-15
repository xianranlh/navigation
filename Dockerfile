FROM nginx:alpine

# 设置维护者信息
LABEL maintainer="xianranlh"
LABEL description="Personal Navigation Page"

# 复制自定义nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 复制网站文件到nginx默认目录
COPY index.html /usr/share/nginx/html/
COPY css/ /usr/share/nginx/html/css/
COPY js/ /usr/share/nginx/html/js/

# 设置文件权限
RUN chmod -R 755 /usr/share/nginx/html

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
