(() => {
  function isLocalDevelopmentHost(hostname) {
    return (
      hostname === 'localhost' ||
      hostname === '127.0.0.1' ||
      hostname.endsWith('.local')
    );
  }

  function normalizeApiBaseUrl(value) {
    return String(value || '').trim().replace(/\/+$/, '');
  }

  function computeDefaultApiBaseUrl() {
    const { hostname, origin, port } = window.location;

    if (isLocalDevelopmentHost(hostname) || port === '8081') {
      return `http://${hostname}:8000/api`;
    }

    return `${origin}/api`;
  }

  const runtimeConfig = window.__QHEWTEK_CONFIG__ || {};

  window.APP_CONFIG = {
    apiBaseUrl: normalizeApiBaseUrl(
      runtimeConfig.apiBaseUrl || computeDefaultApiBaseUrl(),
    ),
    currency: runtimeConfig.currency || 'USD',
    brandName: runtimeConfig.brandName || 'QhewTek Coffee',
  };
})();
