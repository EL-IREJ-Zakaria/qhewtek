document.addEventListener('DOMContentLoaded', () => {
  const tableToken = window.QhewTekCommon.getTableToken();
  const cartItems = document.getElementById('cartItems');
  const cartEmpty = document.getElementById('cartEmpty');

  function updateSummary() {
    const summary = window.QhewTekStore.summary(tableToken);
    window.QhewTekCommon.setElementText('tableBadge', tableToken ? `QR ${tableToken}` : 'Waiting for table QR');
    window.QhewTekCommon.setElementText('cartCountLabel', `${summary.totalItems} items`);
    window.QhewTekCommon.setElementText('summaryItemCount', `${summary.totalItems}`);
    window.QhewTekCommon.setElementText('summaryTotal', window.QhewTekCommon.currency(summary.totalPrice));
  }

  function renderCart() {
    const summary = window.QhewTekStore.summary(tableToken);

    cartEmpty.classList.toggle('d-none', summary.items.length !== 0);
    cartItems.innerHTML = summary.items
      .map((item) => `
        <article class="cart-item-card">
          <div class="cart-item-head">
            ${
              item.image_url
                ? `<img class="cart-thumb" src="${window.QhewTekCommon.escapeHtml(item.image_url)}" alt="${window.QhewTekCommon.escapeHtml(item.name)}" />`
                : '<div class="cart-thumb d-flex align-items-center justify-content-center muted-copy">No image</div>'
            }
            <div class="flex-grow-1">
              <div class="title-row">
                <div>
                  <div class="eyebrow">${window.QhewTekCommon.escapeHtml(item.category)}</div>
                  <h3>${window.QhewTekCommon.escapeHtml(item.name)}</h3>
                </div>
                <span class="price-pill">${window.QhewTekCommon.currency(item.price * item.quantity)}</span>
              </div>
              <div class="item-footer">
                <div class="quantity-stepper">
                  <button class="stepper-button" type="button" data-step="-1" data-id="${item.menu_item_id}">-</button>
                  <span class="stepper-value">${item.quantity}</span>
                  <button class="stepper-button" type="button" data-step="1" data-id="${item.menu_item_id}">+</button>
                </div>
                <button class="btn btn-link text-danger p-0 fw-bold" type="button" data-remove="${item.menu_item_id}">Remove</button>
              </div>
            </div>
          </div>
        </article>
      `)
      .join('');

    cartItems.querySelectorAll('[data-step]').forEach((button) => {
      button.addEventListener('click', () => {
        const id = Number(button.getAttribute('data-id'));
        const delta = Number(button.getAttribute('data-step'));
        const currentItem = window.QhewTekStore.readCart(tableToken).find((item) => item.menu_item_id === id);
        if (!currentItem) {
          return;
        }

        window.QhewTekStore.updateQuantity(tableToken, id, currentItem.quantity + delta);
        renderCart();
        updateSummary();
      });
    });

    cartItems.querySelectorAll('[data-remove]').forEach((button) => {
      button.addEventListener('click', () => {
        const id = Number(button.getAttribute('data-remove'));
        window.QhewTekStore.removeItem(tableToken, id);
        renderCart();
        updateSummary();
      });
    });
  }

  renderCart();
  updateSummary();
});
