document.addEventListener('DOMContentLoaded', async () => {
  const tableToken = window.QhewTekCommon.getTableToken();
  const state = {
    items: [],
    categories: [],
    activeCategory: '',
    search: '',
    table: null,
  };

  const menuGrid = document.getElementById('menuGrid');
  const menuEmpty = document.getElementById('menuEmpty');
  const pageMessage = document.getElementById('pageMessage');
  const searchInput = document.getElementById('searchInput');
  const categoryFilters = document.getElementById('categoryFilters');

  function setPageError(message) {
    pageMessage.textContent = message;
    pageMessage.classList.remove('d-none');
    menuGrid.innerHTML = '';
    menuEmpty.classList.add('d-none');
  }

  function updateCartDock() {
    const summary = window.QhewTekStore.summary(tableToken);
    window.QhewTekCommon.setElementText('cartItemCount', `${summary.totalItems}`);
    window.QhewTekCommon.setElementText('cartTotal', window.QhewTekCommon.currency(summary.totalPrice));
  }

  function renderCategories() {
    const filters = ['all', ...state.categories];
    categoryFilters.innerHTML = filters
      .map((category) => {
        const label = category === 'all' ? 'All items' : category;
        const active = state.activeCategory === category || (state.activeCategory === '' && category === 'all');
        return `
          <button class="filter-chip ${active ? 'active' : ''}" type="button" data-category="${category}">
            ${window.QhewTekCommon.escapeHtml(label)}
          </button>
        `;
      })
      .join('');

    categoryFilters.querySelectorAll('[data-category]').forEach((button) => {
      button.addEventListener('click', () => {
        const category = button.getAttribute('data-category');
        state.activeCategory = category === 'all' ? '' : category;
        renderCategories();
        renderMenu();
      });
    });
  }

  function filteredItems() {
    return state.items.filter((item) => {
      const matchesCategory = !state.activeCategory || item.category === state.activeCategory;
      const searchableText = `${item.name} ${item.description} ${item.category}`.toLowerCase();
      const matchesSearch = searchableText.includes(state.search.toLowerCase());
      return matchesCategory && matchesSearch;
    });
  }

  function renderMenu() {
    const items = filteredItems();

    menuEmpty.classList.toggle('d-none', items.length !== 0);
    menuGrid.innerHTML = items
      .map((item) => `
        <article class="menu-card">
          <div class="menu-card-media">
            ${
              item.image_url
                ? `<img src="${window.QhewTekCommon.escapeHtml(item.image_url)}" alt="${window.QhewTekCommon.escapeHtml(item.name)}" />`
                : '<div class="w-100 h-100 d-flex align-items-center justify-content-center muted-copy">No image</div>'
            }
          </div>
          <div class="menu-card-body">
            <div class="eyebrow">${window.QhewTekCommon.escapeHtml(item.category)}</div>
            <div class="title-row">
              <h3>${window.QhewTekCommon.escapeHtml(item.name)}</h3>
              <span class="price-pill">${window.QhewTekCommon.currency(item.price)}</span>
            </div>
            <p class="muted-copy mb-0">${window.QhewTekCommon.escapeHtml(item.description || 'House favorite crafted to order.')}</p>
            <div class="card-actions">
              <span class="muted-copy small">Freshly available</span>
              <button class="btn btn-brand" type="button" data-add-item="${item.id}">Add to cart</button>
            </div>
          </div>
        </article>
      `)
      .join('');

    menuGrid.querySelectorAll('[data-add-item]').forEach((button) => {
      button.addEventListener('click', () => {
        const itemId = Number(button.getAttribute('data-add-item'));
        const item = state.items.find((entry) => entry.id === itemId);

        if (!item) {
          return;
        }

        window.QhewTekStore.addItem(tableToken, item);
        updateCartDock();
        window.QhewTekCommon.showToast(`${item.name} added to cart`);
      });
    });
  }

  searchInput.addEventListener('input', (event) => {
    state.search = event.target.value.trim();
    renderMenu();
  });

  if (!tableToken) {
    setPageError('This menu is meant to open from a table QR code. Add ?table=TABLE-01 to the URL to simulate a scan.');
    updateCartDock();
    return;
  }

  try {
    const response = await window.QhewTekApi.fetchMenu({ tableToken });
    state.items = response.data.items || [];
    state.categories = response.data.filters?.categories || [];
    state.table = response.data.table;

    const tableLabel = state.table?.table_number
      ? `Table ${state.table.table_number}`
      : `QR ${tableToken}`;

    window.QhewTekCommon.setElementText('tableBadge', tableLabel);
    renderCategories();
    renderMenu();
    updateCartDock();
  } catch (error) {
    setPageError(error.message);
  }
});
