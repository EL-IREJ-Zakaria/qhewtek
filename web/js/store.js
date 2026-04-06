window.QhewTekStore = (() => {
  function cartKey(tableToken) {
    return `qhewtek-cart-${tableToken || 'guest'}`;
  }

  function readCart(tableToken) {
    const raw = localStorage.getItem(cartKey(tableToken));
    if (!raw) {
      return [];
    }

    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch (error) {
      return [];
    }
  }

  function writeCart(tableToken, items) {
    localStorage.setItem(cartKey(tableToken), JSON.stringify(items));
  }

  function addItem(tableToken, item) {
    const cart = readCart(tableToken);
    const existing = cart.find((entry) => entry.menu_item_id === item.id);

    if (existing) {
      existing.quantity += 1;
    } else {
      cart.push({
        menu_item_id: item.id,
        name: item.name,
        price: Number(item.price),
        image_url: item.image_url || '',
        category: item.category,
        quantity: 1,
      });
    }

    writeCart(tableToken, cart);
    return cart;
  }

  function updateQuantity(tableToken, menuItemId, quantity) {
    const cart = readCart(tableToken)
      .map((item) => {
        if (item.menu_item_id === menuItemId) {
          return { ...item, quantity: Math.max(0, quantity) };
        }

        return item;
      })
      .filter((item) => item.quantity > 0);

    writeCart(tableToken, cart);
    return cart;
  }

  function removeItem(tableToken, menuItemId) {
    const cart = readCart(tableToken).filter((item) => item.menu_item_id !== menuItemId);
    writeCart(tableToken, cart);
    return cart;
  }

  function clear(tableToken) {
    localStorage.removeItem(cartKey(tableToken));
  }

  function summary(tableToken) {
    const items = readCart(tableToken);
    const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);
    const totalPrice = items.reduce((sum, item) => sum + item.quantity * Number(item.price), 0);

    return {
      items,
      totalItems,
      totalPrice,
    };
  }

  return {
    readCart,
    addItem,
    updateQuantity,
    removeItem,
    clear,
    summary,
  };
})();
