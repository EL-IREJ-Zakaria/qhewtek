window.QhewTekApi = (() => {
  async function request(path, options = {}) {
    const config = { ...options };
    config.method = config.method || 'GET';
    config.headers = config.headers || {};

    if (!(config.body instanceof FormData)) {
      config.headers['Content-Type'] = 'application/json';
    }

    const response = await fetch(`${window.APP_CONFIG.apiBaseUrl}${path}`, config);
    const payload = await response.json().catch(() => ({
      success: false,
      message: 'Invalid server response.',
    }));

    if (!response.ok || payload.success === false) {
      throw new Error(payload.message || 'Request failed.');
    }

    return payload;
  }

  function fetchMenu({ tableToken = '', search = '', category = '', includeUnavailable = false } = {}) {
    const params = new URLSearchParams();
    if (tableToken) params.set('table', tableToken);
    if (search) params.set('search', search);
    if (category) params.set('category', category);
    if (includeUnavailable) params.set('include_unavailable', '1');

    const queryString = params.toString();
    return request(`/menu${queryString ? `?${queryString}` : ''}`);
  }

  function createOrder(payload) {
    return request('/order/create', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  }

  return {
    fetchMenu,
    createOrder,
  };
})();
