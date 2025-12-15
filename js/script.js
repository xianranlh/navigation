// 搜索功能
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('search-input');
    const searchBtn = document.getElementById('search-btn');
    const linkCards = document.querySelectorAll('.link-card');

    // 搜索引擎配置
    const searchEngines = {
        google: 'https://www.google.com/search?q=',
        baidu: 'https://www.baidu.com/s?wd=',
        bing: 'https://www.bing.com/search?q='
    };

    // 默认使用 Google 搜索
    const defaultEngine = searchEngines.google;

    // 搜索按钮点击事件
    searchBtn.addEventListener('click', function() {
        performSearch();
    });

    // 回车键搜索
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            performSearch();
        }
    });

    // 执行搜索
    function performSearch() {
        const query = searchInput.value.trim();
        if (query) {
            window.open(defaultEngine + encodeURIComponent(query), '_blank');
        }
    }

    // 实时过滤链接
    searchInput.addEventListener('input', function() {
        const query = this.value.toLowerCase().trim();
        
        linkCards.forEach(card => {
            const title = card.querySelector('h3').textContent.toLowerCase();
            const description = card.querySelector('p').textContent.toLowerCase();
            
            if (title.includes(query) || description.includes(query)) {
                card.style.display = 'flex';
            } else {
                card.style.display = query ? 'none' : 'flex';
            }
        });

        // 显示/隐藏分类标题
        document.querySelectorAll('.category').forEach(category => {
            const visibleCards = category.querySelectorAll('.link-card[style*="display: flex"], .link-card:not([style*="display: none"])');
            const hasVisibleCards = Array.from(category.querySelectorAll('.link-card')).some(card => {
                return card.style.display !== 'none';
            });
            
            if (query && !hasVisibleCards) {
                category.style.display = 'none';
            } else {
                category.style.display = 'block';
            }
        });
    });

    // 添加淡入动画
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, {
        threshold: 0.1
    });

    // 为每个链接卡片添加动画
    linkCards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = `all 0.5s ease ${index * 0.05}s`;
        observer.observe(card);
    });

    // 统计功能（调试用）
    if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        console.log(`导航页面已加载 ${linkCards.length} 个链接`);
    }

    // 添加点击统计（可选）
    linkCards.forEach(card => {
        card.addEventListener('click', function() {
            // 这里可以添加数据统计逻辑
            if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
                const title = this.querySelector('h3').textContent;
                console.log(`点击链接: ${title}`);
            }
        });
    });
});
