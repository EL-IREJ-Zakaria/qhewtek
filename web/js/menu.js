document.addEventListener('DOMContentLoaded', async () => {
  const defaultDrinks = [
    {
      category: 'Coffee',
      drinks: [
        { name: 'Espresso', caffeine: 212 },
        { name: 'Cappuccino', caffeine: 40 },
        { name: 'Latte', caffeine: 32 },
        { name: 'Americano', caffeine: 47 },
      ],
    },
    {
      category: 'Tea',
      drinks: [
        { name: 'Green Tea', caffeine: 12 },
        { name: 'Black Tea', caffeine: 20 },
      ],
    },
    {
      category: 'Energy Drinks',
      drinks: [
        { name: 'Red Bull', caffeine: 32 },
        { name: 'Monster', caffeine: 32 },
      ],
    },
    {
      category: 'Soft Drinks',
      drinks: [
        { name: 'Coca-Cola', caffeine: 10 },
        { name: 'Pepsi', caffeine: 11 },
      ],
    },
    {
      category: 'Juice',
      drinks: [
        { name: 'Orange Juice', caffeine: 0 },
        { name: 'Apple Juice', caffeine: 0 },
      ],
    },
  ];

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
  const defaultDrinksGrid = document.getElementById('defaultDrinksGrid');

  function formatCaffeine(value) {
    return value === 0 ? '0 mg caffeine / 100ml' : `${value} mg caffeine / 100ml`;
  }

  function normalizeName(value) {
    return String(value || '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '');
  }

  function findMatchingMenuItem(drink) {
    return state.items.find((item) => normalizeName(item.name) === normalizeName(drink.name));
  }

  function deriveCategories(items) {
    return [...new Set(items.map((item) => item.category).filter(Boolean))].sort((left, right) =>
      left.localeCompare(right)
    );
  }

  function renderDefaultDrinks() {
    if (!defaultDrinksGrid) {
      return;
    }

    defaultDrinksGrid.innerHTML = defaultDrinks
      .map(
        (group) => `
          <article class="reference-card">
            <div class="eyebrow">${window.QhewTekCommon.escapeHtml(group.category)}</div>
            <h3>${window.QhewTekCommon.escapeHtml(group.category)}</h3>
            <div class="reference-list">
              ${group.drinks
                .map((drink) => {
                  const matchedItem = findMatchingMenuItem(drink);
                  return `
                    <div class="reference-item">
                      <div>
                        <div class="reference-name">${window.QhewTekCommon.escapeHtml(drink.name)}</div>
                        <div class="muted-copy small">${formatCaffeine(drink.caffeine)}</div>
                      </div>
                      <button
                        class="btn ${matchedItem ? 'btn-brand' : 'btn-secondary-soft'} reference-action"
                        type="button"
                        ${matchedItem ? `data-default-add="${matchedItem.id}"` : 'disabled'}
                      >
                        ${matchedItem ? 'Add to cart' : 'Unavailable'}
                      </button>
                    </div>
                  `
                })
                .join('')}
            </div>
          </article>
        `
      )
      .join('');

    defaultDrinksGrid.querySelectorAll('[data-default-add]').forEach((button) => {
      button.addEventListener('click', () => {
        const itemId = Number(button.getAttribute('data-default-add'));
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

  renderDefaultDrinks();

  if (!tableToken) {
    setPageError('This menu is meant to open from a table QR code. Add ?table=TABLE-01 to the URL to simulate a scan.');
    updateCartDock();
    return;
  }

  try {
    const response = await window.QhewTekApi.fetchMenu({ tableToken });
    const payload = response.data;

    state.items = Array.isArray(payload) ? payload : payload.items || [];
    state.categories = Array.isArray(payload)
      ? deriveCategories(state.items)
      : payload.filters?.categories || deriveCategories(state.items);
    state.table = Array.isArray(payload) ? null : payload.table || null;

    const tableLabel = state.table?.table_number
      ? `Table ${state.table.table_number}`
      : `QR ${tableToken}`;

    window.QhewTekCommon.setElementText('tableBadge', tableLabel);
    renderCategories();
    renderMenu();
    renderDefaultDrinks();
    updateCartDock();
  } catch (error) {
    setPageError(error.message);
  }
});
