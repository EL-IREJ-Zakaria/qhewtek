document.addEventListener('DOMContentLoaded', () => {
  const tableToken = window.QhewTekCommon.getTableToken();
  const checkoutItems = document.getElementById('checkoutItems');
  const checkoutEmpty = document.getElementById('checkoutEmpty');
  const checkoutPanel = document.getElementById('checkoutPanel');
  const checkoutMessage = document.getElementById('checkoutMessage');
  const submitButton = document.getElementById('submitOrderButton');
  const successPanel = document.getElementById('successPanel');
  const successMeta = document.getElementById('successMeta');
  const successStatus = document.getElementById('successStatus');

  function renderItems() {
    const summary = window.QhewTekStore.summary(tableToken);

    window.QhewTekCommon.setElementText('tableBadge', tableToken ? `QR ${tableToken}` : 'Waiting for table QR');
    window.QhewTekCommon.setElementText('checkoutItemCount', `${summary.totalItems}`);
    window.QhewTekCommon.setElementText('checkoutTotal', window.QhewTekCommon.currency(summary.totalPrice));
    checkoutEmpty.classList.toggle('d-none', summary.items.length !== 0);
    submitButton.disabled = summary.items.length === 0 || !tableToken;

    checkoutItems.innerHTML = summary.items
      .map((item) => `
        <article class="cart-item-card">
          <div class="d-flex justify-content-between align-items-center gap-3">
            <div>
              <div class="eyebrow">${window.QhewTekCommon.escapeHtml(item.category)}</div>
              <h3>${window.QhewTekCommon.escapeHtml(item.name)}</h3>
              <div class="muted-copy">${item.quantity} × ${window.QhewTekCommon.currency(item.price)}</div>
            </div>
            <span class="price-pill">${window.QhewTekCommon.currency(item.quantity * item.price)}</span>
          </div>
        </article>
      `)
      .join('');

    if (!tableToken) {
      checkoutMessage.textContent = 'This page expects a table QR token in the URL, for example ?table=TABLE-01.';
      checkoutMessage.classList.remove('d-none');
    }
  }

  async function submitOrder() {
    const summary = window.QhewTekStore.summary(tableToken);
    if (!tableToken || summary.items.length === 0) {
      return;
    }

    submitButton.disabled = true;
    submitButton.textContent = 'Submitting...';
    checkoutMessage.classList.add('d-none');

    try {
      const response = await window.QhewTekApi.createOrder({
        table_qr_code: tableToken,
        items: summary.items.map((item) => ({
          menu_item_id: item.menu_item_id,
          quantity: item.quantity,
        })),
      });

      const order = response.data.order;
      window.QhewTekStore.clear(tableToken);
      renderItems();

      successStatus.textContent = order.status;
      successStatus.className = `status-pill ${window.QhewTekCommon.statusClass(order.status)} mb-3`;
      successMeta.innerHTML = `
        <div class="summary-card">
          <div class="muted-copy small">Order ID</div>
          <div class="display-font fs-6 fw-bold">#${order.id}</div>
        </div>
        <div class="summary-card">
          <div class="muted-copy small">Total</div>
          <div class="display-font fs-6 fw-bold">${window.QhewTekCommon.currency(order.total_price)}</div>
        </div>
      `;
      successPanel.classList.remove('d-none');
      checkoutPanel.scrollIntoView({ behavior: 'smooth', block: 'start' });
      window.QhewTekCommon.showToast('Order sent to the waiter');
    } catch (error) {
      checkoutMessage.textContent = error.message;
      checkoutMessage.classList.remove('d-none');
    } finally {
      submitButton.disabled = false;
      submitButton.textContent = 'Submit Order';
    }
  }

  submitButton.addEventListener('click', submitOrder);
  renderItems();
});
