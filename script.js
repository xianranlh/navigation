// Theme Management
const themeToggle = document.getElementById('themeToggle');
const html = document.documentElement;

// Load saved theme or default to light
const savedTheme = localStorage.getItem('theme') || 'light';
html.setAttribute('data-theme', savedTheme);

themeToggle.addEventListener('click', () => {
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
});

// Search Functionality
const searchInput = document.getElementById('searchInput');
const searchBtn = document.getElementById('searchBtn');
const searchEngines = document.querySelectorAll('.search-engine');

let currentEngine = 'baidu';

// Search engine URLs
const searchUrls = {
    baidu: 'https://www.baidu.com/s?wd=',
    google: 'https://www.google.com/search?q=',
    bing: 'https://www.bing.com/search?q='
};

// Load saved search engine
const savedEngine = localStorage.getItem('searchEngine') || 'baidu';
currentEngine = savedEngine;
updateActiveEngine();

// Search engine selection
searchEngines.forEach(engine => {
    engine.addEventListener('click', () => {
        currentEngine = engine.getAttribute('data-engine');
        localStorage.setItem('searchEngine', currentEngine);
        updateActiveEngine();
    });
});

function updateActiveEngine() {
    searchEngines.forEach(engine => {
        if (engine.getAttribute('data-engine') === currentEngine) {
            engine.classList.add('active');
        } else {
            engine.classList.remove('active');
        }
    });
}

// Search button click
searchBtn.addEventListener('click', performSearch);

// Enter key to search
searchInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        performSearch();
    }
});

function performSearch() {
    const query = searchInput.value.trim();
    
    if (query === '') {
        return;
    }
    
    // Check if input is a URL
    function isValidUrl(string) {
        try {
            const url = string.startsWith('http') ? string : 'https://' + string;
            new URL(url);
            return true;
        } catch {
            return false;
        }
    }
    
    if (isValidUrl(query)) {
        // If it looks like a URL, navigate to it
        const url = query.startsWith('http') ? query : 'https://' + query;
        window.open(url, '_blank');
    } else {
        // Otherwise, use the selected search engine
        const searchUrl = searchUrls[currentEngine] + encodeURIComponent(query);
        window.open(searchUrl, '_blank');
    }
    
    // Clear input
    searchInput.value = '';
}

// Auto-focus search input on page load
window.addEventListener('load', () => {
    searchInput.focus();
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Focus search with '/' key
    if (e.key === '/' && document.activeElement !== searchInput) {
        e.preventDefault();
        searchInput.focus();
    }
    
    // Clear search with Escape key
    if (e.key === 'Escape' && document.activeElement === searchInput) {
        searchInput.value = '';
        searchInput.blur();
    }
});

// Add smooth scroll behavior
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Link card animation on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all link cards for animation
document.querySelectorAll('.link-card').forEach(card => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
    observer.observe(card);
});
