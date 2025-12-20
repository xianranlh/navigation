<template>
  <div class="admin-page">
    <h1 class="page-title">管理中心</h1>
    <p class="page-desc">管理你的分类和链接</p>

    <!-- 功能开发中提示 -->
    <div class="glass-card coming-soon">
      <span class="icon">🚧</span>
      <h3>功能开发中</h3>
      <p>管理页面正在建设中，敬请期待...</p>
      <router-link to="/" class="glass-button glass-button-primary">
        返回首页
      </router-link>
    </div>
  </div>
</template>

<style scoped>
.admin-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px 0;
  text-align: center;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--hsr-text-primary);
  margin: 0 0 8px 0;
}

.page-desc {
  color: var(--hsr-text-muted);
  margin: 0 0 40px 0;
}

.coming-soon {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 60px 40px;
}

.coming-soon .icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.coming-soon h3 {
  font-size: 20px;
  color: var(--hsr-text-primary);
  margin: 0 0 8px 0;
}

.coming-soon p {
  color: var(--hsr-text-muted);
  margin: 0 0 24px 0;
}
</style>
