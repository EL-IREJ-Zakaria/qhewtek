window.QhewTekCommon = (() => {
  const THEME_KEY = 'qhewtek-theme';
  const TABLE_KEY = 'qhewtek-table-qr';
  let toastTimer = null;

  function escapeHtml(value = '') {
    return String(value)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }

  function currency(value) {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: window.APP_CONFIG.currency,
    }).format(Number(value || 0));
  }

  function getTableToken() {
    const params = new URLSearchParams(window.location.search);
    const fromQuery = params.get('table');
    if (fromQuery) {
      localStorage.setItem(TABLE_KEY, fromQuery);
      return fromQuery;
    }

    return localStorage.getItem(TABLE_KEY) || '';
  }

  function buildPageUrl(pageName) {
    const token = getTableToken();
    return token ? `./${pageName}?table=${encodeURIComponent(token)}` : `./${pageName}`;
  }

  function syncPageLinks() {
    const token = getTableToken();
    document.querySelectorAll('[data-table-link]').forEach((anchor) => {
      const target = anchor.getAttribute('data-table-link');
      anchor.setAttribute('href', token ? `./${target}?table=${encodeURIComponent(token)}` : `./${target}`);
    });
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem(THEME_KEY, theme);

    const icon = document.querySelector('[data-theme-icon]');
    if (icon) {
      icon.className = theme === 'dark' ? 'bi bi-sun-fill' : 'bi bi-moon-stars-fill';
    }
  }

  function initTheme() {
    const savedTheme = localStorage.getItem(THEME_KEY);
    const preferredTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    applyTheme(savedTheme || preferredTheme);

    const toggle = document.getElementById('themeToggle');
    if (toggle) {
      toggle.addEventListener('click', () => {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        applyTheme(currentTheme === 'dark' ? 'light' : 'dark');
      });
    }
  }

  function showToast(message) {
    let banner = document.getElementById('toastBanner');
    if (!banner) {
      banner = document.createElement('div');
      banner.id = 'toastBanner';
      banner.className = 'toast-banner is-hidden';
      document.body.appendChild(banner);
    }

    banner.textContent = message;
    banner.classList.remove('is-hidden');

    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => {
      banner.classList.add('is-hidden');
    }, 2200);
  }

  function statusClass(status) {
    switch (status) {
      case 'confirmed':
        return 'status-confirmed';
      case 'served':
        return 'status-served';
      default:
        return 'status-pending';
    }
  }

  function setElementText(id, value) {
    const element = document.getElementById(id);
    if (element) {
      element.textContent = value;
    }
  }

  document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    syncPageLinks();
  });

  return {
    escapeHtml,
    currency,
    getTableToken,
    buildPageUrl,
    syncPageLinks,
    showToast,
    statusClass,
    setElementText,
  };
})();
