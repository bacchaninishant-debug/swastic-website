/**
 * VELORA - Interactive Functionality
 * - Dynamic Diamond Shape Ring Switcher (Image 4)
 * - Sticky Navbar Header Color Transition (Images 1 -> 2-5)
 * - Wishlist Favorites Management
 * - Shopping Bag Drawer & Ring Customization Modal
 * - May We Assist You? Concierge Drawer
 */

document.addEventListener('DOMContentLoaded', () => {
  // 1. Sticky Header Color Transition
  const siteHeader = document.getElementById('siteHeader');
  
  const handleScroll = () => {
    if (window.scrollY > 60) {
      siteHeader.classList.add('scrolled');
    } else {
      siteHeader.classList.remove('scrolled');
    }
  };
  
  window.addEventListener('scroll', handleScroll, { passive: true });
  handleScroll();

  // 2. Interactive Diamond Shape Ring Switcher (Image 4)
  const shapeButtons = document.querySelectorAll('.diamond-shape-btn');
  const activeRingImg = document.getElementById('activeRingImage');
  const currentCutBadge = document.getElementById('currentCutBadge');
  const currentCaratBadge = document.getElementById('currentCaratBadge');
  const stageFavBtn = document.getElementById('stageFavBtn');
  
  // Cut specifications and pricing data for GIA Certified Gemstones (Loose Stones Only)
  const diamondData = {
    heart: {
      title: 'HEART-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.05 CT • Natural Certified • VVS1 • Ideal Cut • GIA Certified',
      price: '$3,850',
      priceNum: 3850,
      fullTitle: 'SWASTIC EXPORTS Heart Cut Certified Gemstone',
      img: 'images/diamond-blue-heart.jpg'
    },
    pear: {
      title: 'PEAR-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.20 CT • Natural Certified • VVS1 • Teardrop Elegance • GIA Certified',
      price: '$4,100',
      priceNum: 4100,
      fullTitle: 'SWASTIC EXPORTS Pear Cut Certified Gemstone',
      img: 'images/diamond-blue-pear.jpg'
    },
    princess: {
      title: 'PRINCESS-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.03 CT • Natural Certified • VVS2 • Square Fire • GIA Certified',
      price: '$3,950',
      priceNum: 3950,
      fullTitle: 'SWASTIC EXPORTS Princess Cut Certified Gemstone',
      img: 'images/diamond-blue-princess.jpg'
    },
    emerald: {
      title: 'EMERALD-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.45 CT • Natural Certified • VVS1 • Step Cut Hall of Mirrors • GIA Certified',
      price: '$4,400',
      priceNum: 4400,
      fullTitle: 'SWASTIC EXPORTS Emerald Cut Certified Gemstone',
      img: 'images/diamond-blue-emerald.jpg'
    },
    round: {
      title: 'ROUND-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.00 CT • Natural Certified • VVS1 • 57 Facet Brilliant Fire • GIA Certified',
      price: '$4,250',
      priceNum: 4250,
      fullTitle: 'SWASTIC EXPORTS Round Brilliant Certified Gemstone',
      img: 'images/diamond-blue-round.jpg'
    },
    oval: {
      title: 'OVAL-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.15 CT • Natural Certified • VVS1 • Royal Silhouette • GIA Certified',
      price: '$4,050',
      priceNum: 4050,
      fullTitle: 'SWASTIC EXPORTS Oval Cut Certified Gemstone',
      img: 'images/diamond-blue-oval.jpg'
    },
    cushion: {
      title: 'CUSHION-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.25 CT • Natural Certified • VVS1 • Soft Pillow Faceting • GIA Certified',
      price: '$3,980',
      priceNum: 3980,
      fullTitle: 'SWASTIC EXPORTS Cushion Cut Certified Gemstone',
      img: 'images/diamond-blue-cushion.jpg'
    },
    marquise: {
      title: 'MARQUISE-CUT GIA CERTIFIED GEMSTONE',
      spec: '2.10 CT • Natural Certified • VVS1 • Dramatic Royal Silhouette • GIA Certified',
      price: '$4,180',
      priceNum: 4180,
      fullTitle: 'SWASTIC EXPORTS Marquise Cut Certified Gemstone',
      img: 'images/diamond-blue-marquise.jpg'
    }
  };

  let currentSelectedShape = 'heart';

  shapeButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      shapeButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      const shape = btn.dataset.shape;
      const targetImgSrc = btn.dataset.img;
      const info = diamondData[shape];

      currentSelectedShape = shape;

      if (stageFavBtn) {
        stageFavBtn.classList.toggle('favorited', isItemInFavorites(`shape-${shape}`));
      }

      // Smooth transition animation
      activeRingImg.classList.add('switching');
      
      setTimeout(() => {
        activeRingImg.src = targetImgSrc;
        activeRingImg.alt = info.fullTitle;
        currentCutBadge.textContent = info.title;
        currentCaratBadge.textContent = info.spec;
        
        activeRingImg.onload = () => {
          activeRingImg.classList.remove('switching');
        };
        setTimeout(() => activeRingImg.classList.remove('switching'), 150);
      }, 150);

      // Sync the top Shop by Shape row
      document.querySelectorAll('.shape-select-item').forEach(el => {
        el.classList.toggle('active', el.dataset.shape === shape);
      });
    });
  });

  // Global helper for the Shop by Shape horizontal strip
  window.selectShapeCut = function(shape) {
    const btn = document.querySelector(`.diamond-shape-btn[data-shape="${shape}"]`);
    if (btn) {
      btn.click();
    }
    document.querySelectorAll('.shape-select-item').forEach(el => {
      el.classList.toggle('active', el.dataset.shape === shape);
    });
  };

  // Stage Favorite Ring Click
  if (stageFavBtn) {
    stageFavBtn.addEventListener('click', () => {
      const info = diamondData[currentSelectedShape];
      toggleProductFavorite(`shape-${currentSelectedShape}`, info.fullTitle, info.spec, info.price, info.img);
      stageFavBtn.classList.toggle('favorited', isItemInFavorites(`shape-${currentSelectedShape}`));
    });
  }

  // 3. Favorites / Wishlist Management
  let favorites = [];
  const wishlistBtn = document.getElementById('wishlistBtn');
  const closeWishlistBtn = document.getElementById('closeWishlistBtn');
  const wishlistDrawer = document.getElementById('wishlistDrawer');
  const wishlistBackdrop = document.getElementById('wishlistBackdrop');
  const wishlistBadgeCount = document.getElementById('wishlistBadgeCount');
  const wishlistDrawerCount = document.getElementById('wishlistDrawerCount');
  const emptyWishlistView = document.getElementById('emptyWishlistView');
  const wishlistItemsList = document.getElementById('wishlistItemsList');

  function isItemInFavorites(id) {
    return favorites.some(item => item.id === id);
  }

  window.toggleProductFavorite = (id, title, spec, price, img, e) => {
    if (e) {
      e.stopPropagation();
      const heartBtn = e.currentTarget;
      heartBtn.classList.toggle('active');
    }

    const index = favorites.findIndex(item => item.id === id);
    if (index > -1) {
      favorites.splice(index, 1);
    } else {
      favorites.push({ id, title, spec, price, img });
    }

    updateWishlistUI();
  };

  function updateWishlistUI() {
    const count = favorites.length;
    if (wishlistBadgeCount) {
      wishlistBadgeCount.textContent = count;
      wishlistBadgeCount.classList.toggle('has-items', count > 0);
    }
    if (wishlistDrawerCount) wishlistDrawerCount.textContent = count;

    if (stageFavBtn) {
      stageFavBtn.classList.toggle('favorited', isItemInFavorites(`shape-${currentSelectedShape}`));
    }

    if (count === 0) {
      emptyWishlistView.style.display = 'block';
      wishlistItemsList.style.display = 'none';
    } else {
      emptyWishlistView.style.display = 'none';
      wishlistItemsList.style.display = 'block';

      wishlistItemsList.innerHTML = favorites.map((item, idx) => `
        <div class="cart-item-row">
          <img src="${item.img}" alt="${item.title}" class="cart-item-img">
          <div class="cart-item-details">
            <div class="cart-item-title">${item.title}</div>
            <div class="cart-item-meta">${item.spec}</div>
            <div class="cart-item-price">${item.price}</div>
            <div style="display:flex; gap:12px; margin-top:6px;">
              <button class="hero-cta-btn dark-cta" style="padding:6px 12px !important; font-size:10px !important;" onclick="moveFavoriteToBag(${idx})">MOVE TO BAG</button>
              <div class="cart-item-remove" onclick="removeFavoriteItem(${idx})">Remove</div>
            </div>
          </div>
        </div>
      `).join('');
    }
  }

  window.removeFavoriteItem = (idx) => {
    favorites.splice(idx, 1);
    updateWishlistUI();
  };

  window.moveFavoriteToBag = (idx) => {
    const fav = favorites[idx];
    const priceNum = parseInt(fav.price.replace(/[^0-9]/g, '')) || 2950;
    quickAddProduct(fav.id, fav.title, fav.spec, priceNum, fav.img);
    removeFavoriteItem(idx);
    closeWishlist();
  };

  const openWishlist = () => {
    wishlistDrawer.classList.add('active');
    wishlistBackdrop.classList.add('active');
  };

  const closeWishlist = () => {
    wishlistDrawer.classList.remove('active');
    wishlistBackdrop.classList.remove('active');
  };

  if (wishlistBtn) wishlistBtn.addEventListener('click', openWishlist);
  if (closeWishlistBtn) closeWishlistBtn.addEventListener('click', closeWishlist);
  if (wishlistBackdrop) wishlistBackdrop.addEventListener('click', closeWishlist);

  // 4. Shopping Bag Drawer State
  const cartBtn = document.getElementById('cartBtn');
  const closeCartBtn = document.getElementById('closeCartBtn');
  const cartDrawer = document.getElementById('cartDrawer');
  const cartBackdrop = document.getElementById('cartBackdrop');
  const cartBadgeCount = document.getElementById('cartBadgeCount');
  const drawerCount = document.getElementById('drawerCount');
  const emptyCartView = document.getElementById('emptyCartView');
  const cartItemsList = document.getElementById('cartItemsList');
  const cartDrawerFooter = document.getElementById('cartDrawerFooter');
  const cartSubtotalValue = document.getElementById('cartSubtotalValue');

  // Load persisted cart from localStorage
  let cart = [];
  try {
    const saved = localStorage.getItem('swastic_gem_cart');
    if (saved) cart = JSON.parse(saved);
  } catch(e) {}

  const saveCart = () => {
    try {
      localStorage.setItem('swastic_gem_cart', JSON.stringify(cart));
    } catch(e) {}
  };

  const updateCartUI = () => {
    const totalItems = cart.reduce((sum, item) => sum + (item.quantity || 1), 0);
    if (cartBadgeCount) {
      cartBadgeCount.textContent = totalItems;
      cartBadgeCount.classList.toggle('has-items', totalItems > 0);
    }
    if (drawerCount) drawerCount.textContent = totalItems;

    if (cart.length === 0) {
      if (emptyCartView) emptyCartView.style.display = 'block';
      if (cartItemsList) cartItemsList.style.display = 'none';
      if (cartDrawerFooter) cartDrawerFooter.style.display = 'none';
    } else {
      if (emptyCartView) emptyCartView.style.display = 'none';
      if (cartItemsList) cartItemsList.style.display = 'block';
      if (cartDrawerFooter) cartDrawerFooter.style.display = 'block';

      let subtotal = 0;
      cartItemsList.innerHTML = cart.map((item, idx) => {
        const qty = item.quantity || 1;
        const itemTotal = item.priceNum * qty;
        subtotal += itemTotal;
        return `
          <div class="cart-item-row" data-id="${item.id}">
            <img src="${item.img}" alt="${item.title}" class="cart-item-img">
            <div class="cart-item-details">
              <div class="cart-item-title">${item.title}</div>
              <div class="cart-item-meta">${item.spec}</div>
              <div class="cart-item-price-row">
                <span class="cart-item-price">$${itemTotal.toLocaleString()}</span>
                ${qty > 1 ? `<span class="cart-item-unit-note">($${item.priceNum.toLocaleString()} each)</span>` : ''}
              </div>
              <div class="cart-qty-wrapper">
                <div class="cart-qty-btn-group">
                  <button type="button" class="cart-qty-btn" onclick="changeCartQty(${idx}, -1)" aria-label="Decrease quantity" title="Decrease quantity">−</button>
                  <span class="cart-qty-val">${qty}</span>
                  <button type="button" class="cart-qty-btn" onclick="changeCartQty(${idx}, 1)" aria-label="Increase quantity" title="Increase quantity">+</button>
                </div>
                <button type="button" class="cart-item-remove-link" onclick="removeCartItem(${idx})">Remove</button>
              </div>
            </div>
          </div>
        `;
      }).join('');

      if (cartSubtotalValue) {
        cartSubtotalValue.textContent = `$${subtotal.toLocaleString()}.00`;
      }
    }
  };

  const openCart = () => {
    if (cartDrawer) cartDrawer.classList.add('active');
    if (cartBackdrop) cartBackdrop.classList.add('active');
  };

  const closeCart = () => {
    if (cartDrawer) cartDrawer.classList.remove('active');
    if (cartBackdrop) cartBackdrop.classList.remove('active');
  };

  if (cartBtn) cartBtn.addEventListener('click', openCart);
  if (closeCartBtn) closeCartBtn.addEventListener('click', closeCart);
  if (cartBackdrop) cartBackdrop.addEventListener('click', closeCart);

  // Global Cart Manipulation Methods
  window.changeCartQty = (idx, delta) => {
    if (!cart[idx]) return;
    const newQty = (cart[idx].quantity || 1) + delta;
    if (newQty <= 0) {
      cart.splice(idx, 1);
    } else {
      cart[idx].quantity = newQty;
    }
    saveCart();
    updateCartUI();
    if (document.getElementById('checkoutModalBackdrop')?.classList.contains('active')) {
      renderCheckoutSummary();
    }
  };

  window.removeCartItem = (idx) => {
    cart.splice(idx, 1);
    saveCart();
    updateCartUI();
    if (document.getElementById('checkoutModalBackdrop')?.classList.contains('active')) {
      renderCheckoutSummary();
    }
  };

  window.quickAddProduct = (id, title, spec, priceNum, img) => {
    const existingIndex = cart.findIndex(item => item.id === id);
    if (existingIndex > -1) {
      cart[existingIndex].quantity = (cart[existingIndex].quantity || 1) + 1;
    } else {
      cart.push({
        id,
        title,
        spec,
        priceNum,
        img,
        quantity: 1
      });
    }

    saveCart();
    updateCartUI();
    openCart();
  };

  // Initial cart UI render
  updateCartUI();

  // =========================================================================
  // SECURE ATELIER CHECKOUT & PAYMENT FLOW
  // =========================================================================
  const checkoutModalBackdrop = document.getElementById('checkoutModalBackdrop');
  const closeCheckoutBtn = document.getElementById('closeCheckoutBtn');
  const checkoutItemsList = document.getElementById('checkoutItemsList');
  const checkoutSubtotal = document.getElementById('checkoutSubtotal');
  const checkoutGrandTotal = document.getElementById('checkoutGrandTotal');
  const payBtnLabel = document.getElementById('payBtnLabel');
  const confirmPayBtn = document.getElementById('confirmPayBtn');
  const checkoutFlowGrid = document.getElementById('checkoutFlowGrid');
  const orderSuccessView = document.getElementById('orderSuccessView');
  const successOrderId = document.getElementById('successOrderId');
  const successReceiptDetails = document.getElementById('successReceiptDetails');
  const successContinueBtn = document.getElementById('successContinueBtn');
  const successPrintBtn = document.getElementById('successPrintBtn');
  const applyCouponBtn = document.getElementById('applyCouponBtn');
  const couponCodeInput = document.getElementById('couponCodeInput');
  const couponMessage = document.getElementById('couponMessage');
  const discountLine = document.getElementById('discountLine');
  const checkoutDiscount = document.getElementById('checkoutDiscount');

  let activeDiscountPercent = 0;

  const renderCheckoutSummary = () => {
    if (!checkoutItemsList) return;
    if (cart.length === 0) {
      checkoutItemsList.innerHTML = `<p style="padding:20px;text-align:center;color:#888;">No items in cart</p>`;
      if (checkoutSubtotal) checkoutSubtotal.textContent = "$0.00";
      if (checkoutGrandTotal) checkoutGrandTotal.textContent = "$0.00";
      if (payBtnLabel) payBtnLabel.textContent = "COMPLETE SECURE ORDER — $0.00";
      return;
    }

    let subtotal = 0;
    checkoutItemsList.innerHTML = cart.map((item) => {
      const qty = item.quantity || 1;
      const lineTotal = item.priceNum * qty;
      subtotal += lineTotal;
      return `
        <div class="checkout-item-card">
          <img src="${item.img}" alt="${item.title}" class="checkout-item-thumb">
          <div class="checkout-item-info">
            <div class="checkout-item-title">${item.title}</div>
            <div class="checkout-item-spec">${item.spec}</div>
            <div class="checkout-item-qty-tag">Quantity: ${qty}</div>
          </div>
          <div class="checkout-item-price-col">
            <div class="checkout-item-line-total">$${lineTotal.toLocaleString()}</div>
          </div>
        </div>
      `;
    }).join('');

    const discountAmount = Math.round(subtotal * (activeDiscountPercent / 100));
    const grandTotal = Math.max(0, subtotal - discountAmount);

    if (checkoutSubtotal) checkoutSubtotal.textContent = `$${subtotal.toLocaleString()}.00`;
    if (discountLine) {
      if (activeDiscountPercent > 0) {
        discountLine.style.display = 'flex';
        if (checkoutDiscount) checkoutDiscount.textContent = `-$${discountAmount.toLocaleString()}.00`;
      } else {
        discountLine.style.display = 'none';
      }
    }
    if (checkoutGrandTotal) checkoutGrandTotal.textContent = `$${grandTotal.toLocaleString()}.00`;
    if (payBtnLabel) payBtnLabel.textContent = `CONFIRM & PAY $${grandTotal.toLocaleString()} NOW`;
  };

  const openCheckout = () => {
    if (cart.length === 0) {
      alert("Your shopping bag is currently empty. Please select a certified gemstone first.");
      return;
    }
    closeCart();
    if (checkoutFlowGrid) checkoutFlowGrid.style.display = 'grid';
    if (orderSuccessView) orderSuccessView.style.display = 'none';
    renderCheckoutSummary();
    if (checkoutModalBackdrop) {
      checkoutModalBackdrop.classList.add('active');
      document.body.style.overflow = 'hidden';
    }
  };

  const closeCheckout = () => {
    if (checkoutModalBackdrop) {
      checkoutModalBackdrop.classList.remove('active');
      document.body.style.overflow = '';
    }
  };

  // Wire all checkout buttons on the page
  document.querySelectorAll('.checkout-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      openCheckout();
    });
  });

  if (closeCheckoutBtn) closeCheckoutBtn.addEventListener('click', closeCheckout);
  if (checkoutModalBackdrop) {
    checkoutModalBackdrop.addEventListener('click', (e) => {
      if (e.target === checkoutModalBackdrop) closeCheckout();
    });
  }

  // Payment Tabs Switcher
  const payTabBtns = document.querySelectorAll('.pay-tab-btn');
  payTabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      payTabBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const tab = btn.getAttribute('data-tab');
      document.querySelectorAll('.payment-tab-content').forEach(p => p.style.display = 'none');
      if (tab === 'card') {
        const c = document.getElementById('tabContentCard');
        if (c) c.style.display = 'block';
      } else if (tab === 'upi') {
        const u = document.getElementById('tabContentUpi');
        if (u) u.style.display = 'block';
      } else if (tab === 'wire') {
        const w = document.getElementById('tabContentWire');
        if (w) w.style.display = 'block';
      }
    });
  });

  // Card formatting helpers
  const cardNum = document.getElementById('cardNum');
  if (cardNum) {
    cardNum.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 16);
      let formatted = val.match(/.{1,4}/g)?.join(' ') || val;
      e.target.value = formatted;
    });
  }

  const cardExp = document.getElementById('cardExp');
  if (cardExp) {
    cardExp.addEventListener('input', (e) => {
      let val = e.target.value.replace(/\D/g, '').substring(0, 4);
      if (val.length >= 3) {
        e.target.value = `${val.substring(0, 2)}/${val.substring(2)}`;
      } else {
        e.target.value = val;
      }
    });
  }

  // Coupon handling
  if (applyCouponBtn && couponCodeInput) {
    applyCouponBtn.addEventListener('click', () => {
      const code = couponCodeInput.value.trim().toUpperCase();
      if (code === 'SWASTIC10' || code === 'ROYAL10' || code === 'WELCOME10') {
        activeDiscountPercent = 10;
        if (couponMessage) {
          couponMessage.className = 'coupon-msg success';
          couponMessage.textContent = '✓ 10% Atelier Courtesy Discount applied successfully!';
        }
        renderCheckoutSummary();
      } else if (code) {
        if (couponMessage) {
          couponMessage.className = 'coupon-msg error';
          couponMessage.textContent = 'Invalid code. Try "SWASTIC10" for 10% courtesy discount.';
        }
      }
    });
  }

  // Confirm Payment Action
  if (confirmPayBtn) {
    confirmPayBtn.addEventListener('click', () => {
      const email = document.getElementById('checkoutEmail')?.value.trim();
      const firstName = document.getElementById('checkoutFirstName')?.value.trim();
      const lastName = document.getElementById('checkoutLastName')?.value.trim();
      const address = document.getElementById('checkoutAddress')?.value.trim();

      if (!email || !firstName || !address) {
        alert("Please provide your delivery contact information (Email, Name, Address) for insured armored dispatch.");
        document.getElementById('checkoutEmail')?.focus();
        return;
      }

      // Show processing animation
      confirmPayBtn.disabled = true;
      confirmPayBtn.innerHTML = `
        <span class="pay-btn-icon">⏳</span>
        <span class="pay-btn-text">Securing Escrow & Authorizing Payment...</span>
      `;

      setTimeout(() => {
        confirmPayBtn.disabled = false;
        confirmPayBtn.innerHTML = `
          <span class="pay-btn-icon">🔒</span>
          <span class="pay-btn-text" id="payBtnLabel">COMPLETE SECURE ORDER</span>
        `;

        // Switch to Order Confirmed state
        if (checkoutFlowGrid) checkoutFlowGrid.style.display = 'none';
        if (orderSuccessView) orderSuccessView.style.display = 'block';

        const randId = `SE-2026-${Math.floor(10000 + Math.random() * 90000)}`;
        if (successOrderId) successOrderId.textContent = randId;

        let totalCharged = 0;
        const itemsHtml = cart.map(item => {
          const qty = item.quantity || 1;
          const line = item.priceNum * qty;
          totalCharged += line;
          return `<tr><td style="padding:6px 0;">${item.title} (x${qty})</td><td style="text-align:right;font-weight:600;">$${line.toLocaleString()}</td></tr>`;
        }).join('');

        const discountAmt = Math.round(totalCharged * (activeDiscountPercent / 100));
        const finalCharged = Math.max(0, totalCharged - discountAmt);

        if (successReceiptDetails) {
          successReceiptDetails.innerHTML = `
            <table style="width:100%;font-size:12.5px;border-collapse:collapse;color:#333;">
              <tr><td style="padding:4px 0;color:#777;">Client Name:</td><td style="text-align:right;font-weight:600;">${firstName} ${lastName || ''}</td></tr>
              <tr><td style="padding:4px 0;color:#777;">Email:</td><td style="text-align:right;font-weight:600;">${email}</td></tr>
              <tr><td style="padding:4px 0;color:#777;">Shipping Destination:</td><td style="text-align:right;font-weight:600;">${address}</td></tr>
              <tr><td style="padding:4px 0;color:#777;">Shipping Protocol:</td><td style="text-align:right;font-weight:600;color:#15803d;">Complimentary Armored Courier (Brink's / FedEx)</td></tr>
              <tr><td colspan="2" style="padding:10px 0 6px;border-bottom:1px solid #eee;font-weight:700;color:#111;">Purchased Gemstones:</td></tr>
              ${itemsHtml}
              ${activeDiscountPercent > 0 ? `<tr><td style="padding:6px 0;color:#15803d;">Courtesy Discount (${activeDiscountPercent}%):</td><td style="text-align:right;color:#15803d;">-$${discountAmt.toLocaleString()}</td></tr>` : ''}
              <tr style="border-top:1px solid #111;font-size:14px;font-weight:700;"><td style="padding:10px 0 4px;">Total Paid:</td><td style="text-align:right;padding:10px 0 4px;color:#111;">$${finalCharged.toLocaleString()}.00</td></tr>
            </table>
          `;
        }

        // Empty cart and reset
        cart = [];
        saveCart();
        updateCartUI();
      }, 1200);
    });
  }

  if (successContinueBtn) {
    successContinueBtn.addEventListener('click', () => {
      closeCheckout();
    });
  }

  if (successPrintBtn) {
    successPrintBtn.addEventListener('click', () => {
      window.print();
    });
  }

  const customizeRingBtn = document.getElementById('customizeRingBtn');
  if (customizeRingBtn) {
    customizeRingBtn.addEventListener('click', () => {
      const info = diamondData[currentSelectedShape];
      quickAddProduct(`shape-${currentSelectedShape}`, info.fullTitle, info.spec, info.priceNum, info.img);
    });
  }

  // 5. Certified Specs Modal
  const viewSpecsBtn = document.getElementById('viewSpecsBtn');
  const specsModalBackdrop = document.getElementById('specsModalBackdrop');
  const closeSpecsModal = document.getElementById('closeSpecsModal');
  const modalShapeTitle = document.getElementById('modalShapeTitle');
  const modalShapeVal = document.getElementById('modalShapeVal');
  const modalAddBagBtn = document.getElementById('modalAddBagBtn');

  if (viewSpecsBtn && specsModalBackdrop) {
    viewSpecsBtn.addEventListener('click', () => {
      const info = diamondData[currentSelectedShape];
      modalShapeTitle.textContent = `${info.title} SPECIFICATIONS`;
      modalShapeVal.textContent = `${currentSelectedShape.charAt(0).toUpperCase() + currentSelectedShape.slice(1)} Cut • ${info.spec}`;
      specsModalBackdrop.classList.add('active');
    });

    if (closeSpecsModal) {
      closeSpecsModal.addEventListener('click', () => {
        specsModalBackdrop.classList.remove('active');
      });
    }

    specsModalBackdrop.addEventListener('click', (e) => {
      if (e.target === specsModalBackdrop) {
        specsModalBackdrop.classList.remove('active');
      }
    });

    if (modalAddBagBtn) {
      modalAddBagBtn.addEventListener('click', () => {
        specsModalBackdrop.classList.remove('active');
        const info = diamondData[currentSelectedShape];
        quickAddProduct(`shape-${currentSelectedShape}`, info.fullTitle, info.spec, info.priceNum, info.img);
      });
    }
  }

  // 6. Floating Concierge Widget ("MAY WE ASSIST YOU?")
  const conciergeTrigger = document.getElementById('conciergeTrigger');
  const conciergePanel = document.getElementById('conciergePanel');
  const conciergeClose = document.getElementById('conciergeClose');
  const conciergeInput = document.getElementById('conciergeInput');
  const conciergeSendBtn = document.getElementById('conciergeSendBtn');

  if (conciergeTrigger && conciergePanel) {
    conciergeTrigger.addEventListener('click', () => {
      conciergePanel.classList.toggle('open');
    });

    if (conciergeClose) {
      conciergeClose.addEventListener('click', (e) => {
        e.stopPropagation();
        conciergePanel.classList.remove('open');
      });
    }

    const sendConciergeMessage = () => {
      const text = conciergeInput.value.trim();
      if (!text) return;
      
      const greeting = document.querySelector('.concierge-greeting');
      if (greeting) {
        greeting.innerHTML = `<strong>You:</strong> ${text}<br><br><strong>Swastic Exports Gemologist:</strong> Thank you for asking. Our gemstone specialist is reviewing your inquiry about "${text}". We can assist you live at 1.844.400.0065 or set up a bespoke digital showcase!`;
      }
      conciergeInput.value = '';
    };

    if (conciergeSendBtn) {
      sendConciergeBtn = conciergeSendBtn;
      conciergeSendBtn.addEventListener('click', sendConciergeMessage);
    }
    if (conciergeInput) {
      conciergeInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendConciergeMessage();
      });
    }
  }

  window.handleConciergeTopic = (topic) => {
    const greeting = document.querySelector('.concierge-greeting');
    if (!greeting) return;

    if (topic === 'diamond-guide') {
      greeting.innerHTML = `<strong>Swastic Exports Guide:</strong> The <strong>Round Brilliant</strong> offers maximum brilliance with 57 facets, while the <strong>Emerald Cut</strong> provides vintage architectural symmetry. Try clicking through our 8 shapes above to see each cut on the gemstone display!`;
    } else if (topic === 'lab-vs-natural') {
      greeting.innerHTML = `<strong>Natural vs Lab Gemstones:</strong> Both possess identical chemical, optical, and physical properties. Swastic Exports lab gemstones are conflict-free and offer larger carat weights at exceptional value with IGI certification.`;
    } else if (topic === 'custom-ring') {
      greeting.innerHTML = `<strong>Custom Design:</strong> Our 7th-generation master jewelers can handcraft any custom design. Call 1.844.400.0065 or click 'Customize in this shape' on your favorite gemstone!`;
    }
  };

  // Search Bar Trigger
  const searchTrigger = document.getElementById('searchTrigger');
  if (searchTrigger) {
    searchTrigger.addEventListener('click', () => {
      const query = prompt('Search SWASTIC EXPORTS Gemstones & Fine Jewelry (e.g., Solitaire, Eternity, Emerald):');
      if (query) {
        alert(`Searching Swastic Exports catalog for "${query}"...`);
      }
    });
  }

  // 6. Featured Diamond & Ring Products Filter & Actions
  window.filterProductCategory = (category) => {
    document.querySelectorAll('.prod-tab-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === category);
    });

    const cards = document.querySelectorAll('.product-item-card');
    cards.forEach(card => {
      const cats = (card.dataset.category || '').split(' ');
      if (category === 'all' || cats.includes(category)) {
        card.style.display = 'flex';
        card.style.opacity = '0';
        card.style.transform = 'translateY(8px)';
        requestAnimationFrame(() => {
          card.style.transition = 'opacity 0.25s ease, transform 0.25s ease';
          card.style.opacity = '1';
          card.style.transform = 'translateY(0)';
        });
      } else {
        card.style.display = 'none';
      }
    });
  };

  window.navigateToCategory = (category, event) => {
    if (event) {
      event.preventDefault();
    }
    // Update active tab and filter items
    window.filterProductCategory(category);
    
    // Smooth scroll to product collection
    const targetSection = document.getElementById('diamond-products-section');
    if (targetSection) {
      const header = document.getElementById('siteHeader');
      const headerHeight = header ? header.offsetHeight : 80;
      const targetPos = targetSection.getBoundingClientRect().top + window.pageYOffset - headerHeight - 15;
      window.scrollTo({
        top: targetPos,
        behavior: 'smooth'
      });
    }

    // Update URL hash cleanly
    if (window.history && window.history.pushState) {
      window.history.pushState(null, null, `#${category}`);
    }
  };

  // Check URL hash on page load or back/forward navigation
  const checkHashCategory = () => {
    const hash = (window.location.hash || '').toLowerCase();
    if (hash === '#gems' || hash.includes('gem')) {
      setTimeout(() => window.navigateToCategory('gems'), 100);
    } else if (hash === '#diamonds' || hash.includes('diamond')) {
      setTimeout(() => window.navigateToCategory('diamonds'), 100);
    }
  };

  window.addEventListener('DOMContentLoaded', checkHashCategory);
  window.addEventListener('hashchange', checkHashCategory);

  window.addProductToBag = (id, title, price, spec, img) => {
    window.quickAddProduct(id, title, spec, price, img);
  };

  window.toggleProductFav = (btn, id, title, price, spec, img) => {
    btn.classList.toggle('favorited');
    window.toggleProductFavorite(id, title, spec, `$${price.toLocaleString()}`, img);
  };

  // 7. Velora Stories Carousel (Arrow Navigation & Touch Drag)
  const storiesTrack = document.getElementById('storiesCardsTrack');
  const storiesPrevBtn = document.getElementById('storiesPrevBtn');
  const storiesNextBtn = document.getElementById('storiesNextBtn');

  if (storiesTrack) {
    if (storiesPrevBtn) {
      storiesPrevBtn.addEventListener('click', () => {
        storiesTrack.scrollBy({ left: -320, behavior: 'smooth' });
      });
    }
    if (storiesNextBtn) {
      storiesNextBtn.addEventListener('click', () => {
        storiesTrack.scrollBy({ left: 320, behavior: 'smooth' });
      });
    }

    // Drag to scroll for desktop mouse users
    let isDown = false;
    let startX;
    let scrollLeft;

    storiesTrack.addEventListener('mousedown', (e) => {
      isDown = true;
      startX = e.pageX - storiesTrack.offsetLeft;
      scrollLeft = storiesTrack.scrollLeft;
    });
    storiesTrack.addEventListener('mouseleave', () => { isDown = false; });
    storiesTrack.addEventListener('mouseup', () => { isDown = false; });
    storiesTrack.addEventListener('mousemove', (e) => {
      if (!isDown) return;
      e.preventDefault();
      const x = e.pageX - storiesTrack.offsetLeft;
      const walk = (x - startX) * 1.5;
      storiesTrack.scrollLeft = scrollLeft - walk;
    });
  }

  // 12. Customer Reviews Interactive Modal (matching Image 1 & Image 2)
  const openReviewsModalBtn = document.getElementById('openReviewsModalBtn');
  const customerReviewsModalBackdrop = document.getElementById('customerReviewsModalBackdrop');
  const closeReviewsModalBtn = document.getElementById('closeReviewsModalBtn');

  if (openReviewsModalBtn && customerReviewsModalBackdrop) {
    openReviewsModalBtn.addEventListener('click', () => {
      customerReviewsModalBackdrop.classList.add('active');
      document.body.style.overflow = 'hidden';
    });

    if (closeReviewsModalBtn) {
      closeReviewsModalBtn.addEventListener('click', () => {
        customerReviewsModalBackdrop.classList.remove('active');
        document.body.style.overflow = '';
      });
    }

    customerReviewsModalBackdrop.addEventListener('click', (e) => {
      if (e.target === customerReviewsModalBackdrop) {
        customerReviewsModalBackdrop.classList.remove('active');
        document.body.style.overflow = '';
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && customerReviewsModalBackdrop.classList.contains('active')) {
        customerReviewsModalBackdrop.classList.remove('active');
        document.body.style.overflow = '';
      }
    });
  }

  // 12.1 Interactive Category Filter & "Load More Reviews" for Natural Gemstones
  const filterChips = document.querySelectorAll('.review-filter-chip');
  const loadMoreBtn = document.getElementById('reviewsLoadMoreBtn');
  const counterNote = document.getElementById('reviewsCounterNote');

  if (filterChips.length > 0) {
    filterChips.forEach(chip => {
      chip.addEventListener('click', () => {
        filterChips.forEach(c => c.classList.remove('active'));
        chip.classList.add('active');
        const filter = chip.getAttribute('data-filter') || 'all';

        const allReviewRows = document.querySelectorAll('.review-item-row');
        let visibleCount = 0;
        allReviewRows.forEach(row => {
          const category = row.getAttribute('data-category');
          if (filter === 'all' || category === filter) {
            row.style.display = 'flex';
            visibleCount++;
          } else {
            row.style.display = 'none';
          }
        });

        if (counterNote) {
          const categoryLabels = {
            all: 'verified client reviews',
            emeralds: 'Zambian Emerald reviews',
            sapphires: 'Ceylon Sapphire reviews',
            rubies: 'Burmese Ruby reviews',
            fancy: 'Precious Gem reviews'
          };
          const totalLabels = {
            all: '1,966',
            emeralds: '620',
            sapphires: '540',
            rubies: '310',
            fancy: '496'
          };
          counterNote.textContent = `Showing ${visibleCount} of ${totalLabels[filter] || '1,966'} ${categoryLabels[filter] || 'reviews'}`;
        }
      });
    });
  }

  // Load More Reviews Handler
  const additionalNaturalGemReviews = [
    {
      avatar: 'DL',
      name: 'Daniel Laurent',
      date: 'Oct 28, 2025',
      category: 'emeralds',
      text: 'Transatlantic delivery was seamless. The 3.85ct untreated Zambian emerald possesses an incredible vivid bluish-green saturation. Swastic Exports included a comprehensive lab dossier and origin authentication.',
      img: 'images/gem-emerald-emerald-hd.jpg',
      title: '3.85 CT Zambian Natural Emerald • Emerald Step Cut'
    },
    {
      avatar: 'MG',
      name: 'Maya Greenfield',
      date: 'Oct 15, 2025',
      category: 'sapphires',
      text: 'My custom cornflower blue sapphire pendant turned out beyond what I could have imagined. Pure fire, silky depth, and ethically mined directly from Ceylon mines by Swastic Exports.',
      img: 'images/product-gem-blue-aquamarine.jpg',
      title: '2.50 CT Natural Ceylon Cornflower Sapphire'
    },
    {
      avatar: 'RH',
      name: 'Dr. Robert Harrison',
      date: 'Sep 30, 2025',
      category: 'rubies',
      text: 'Top tier natural Burmese ruby with intense red fluorescence. Swastic Exports verified the untreated crystalline structure prior to export. Master craftsmanship in every detail.',
      img: 'images/product-gem-red-ruby.jpg',
      title: '3.18 CT Natural Burmese Ruby • Cushion Cut'
    },
    {
      avatar: 'AN',
      name: 'Anoushka Nair',
      date: 'Sep 12, 2025',
      category: 'fancy',
      text: 'The vibrant electric mint glow of this natural tourmaline gemstone is stunning in natural daylight. Swastic Exports is our premier destination for unheated rare gemstones.',
      img: 'images/product-gem-cyan-cushion.jpg',
      title: '4.60 CT Natural Mint Tourmaline / Rare Gemstone'
    },
    {
      avatar: 'CS',
      name: 'Christian Schmidt',
      date: 'Aug 29, 2025',
      category: 'emeralds',
      text: 'Purchased for investment portfolio in Frankfurt. Swastic Exports provided exceptional pricing and high definition micro-gemological photography before final dispatch.',
      img: 'images/gem-emerald-round-hd.jpg',
      title: '4.50 CT Investment Zambian Emerald • Round Cut'
    },
    {
      avatar: 'ZS',
      name: 'Zahra Sayed',
      date: 'Aug 04, 2025',
      category: 'sapphires',
      text: 'A royal blue gemstone worthy of heritage heirlooms. The luster and polish on this cushion sapphire reflects 30+ years of Swastic Exports gem cutting excellence.',
      img: 'images/product-gem-blue-aquamarine.jpg',
      title: '3.40 CT Royal Blue Ceylon Sapphire • Certified'
    }
  ];

  let loadedBatchCount = 0;
  if (loadMoreBtn) {
    loadMoreBtn.addEventListener('click', () => {
      loadMoreBtn.textContent = 'Verifying & Loading Certified Reviews...';
      loadMoreBtn.disabled = true;

      setTimeout(() => {
        const feed = document.getElementById('customerReviewsFeed') || document.querySelector('.customer-reviews-feed');
        if (feed) {
          additionalNaturalGemReviews.forEach(rev => {
            const article = document.createElement('article');
            article.className = 'review-item-row';
            article.setAttribute('data-category', rev.category);
            article.innerHTML = `
              <div class="review-avatar-circle">${rev.avatar}</div>
              <div class="review-item-content">
                <div class="review-item-meta">
                  <span class="review-buyer-name">${rev.name}</span>
                  <span class="review-verified-badge">Verified buyer</span>
                  <span class="review-item-date">• ${rev.date}</span>
                </div>
                <div class="review-item-stars">
                  <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                  <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                  <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                  <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                  <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                </div>
                <p class="review-item-text">${rev.text}</p>
                <div class="review-purchased-badge">
                  <img src="${rev.img}" alt="${rev.title}" class="purchased-thumb">
                  <span class="purchased-title">${rev.title}</span>
                  <div class="purchased-stars">
                    <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                    <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                    <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                    <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                    <svg viewBox="0 0 24 24" fill="#f59e0b"><path d="M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/></svg>
                  </div>
                </div>
              </div>
            `;
            const loadRow = feed.querySelector('.reviews-load-more-row');
            if (loadRow) {
              feed.insertBefore(article, loadRow);
            } else {
              feed.appendChild(article);
            }
          });
        }
        loadedBatchCount++;
        const totalNow = 20 + (loadedBatchCount * 6);
        if (counterNote) {
          counterNote.textContent = `Showing ${totalNow} of 1,966 verified client reviews`;
        }
        loadMoreBtn.textContent = 'LOAD MORE REVIEWS';
        loadMoreBtn.disabled = false;
      }, 450);
    });
  }

  // 13. Choose Your Shape: Native Instagram Video Reel Controller
  const nativeReelVideo = document.getElementById('chooseShapeNativeVideo');
  const reelReplayBtn = document.getElementById('reelReplayBtn');
  const reelMuteToggleBtn = document.getElementById('reelMuteToggleBtn');
  const reelMuteIcon = document.getElementById('reelMuteIcon');

  if (nativeReelVideo) {
    // Ensure loop and continuous replay
    nativeReelVideo.loop = true;
    nativeReelVideo.muted = true;

    // Automatic play attempt with fallback
    const startPlay = () => {
      nativeReelVideo.play().catch(() => {
        nativeReelVideo.muted = true;
        nativeReelVideo.play().catch(e => console.log('Video autoplay deferred:', e));
      });
    };

    startPlay();

    // Auto replay when ended
    nativeReelVideo.addEventListener('ended', () => {
      nativeReelVideo.currentTime = 0;
      nativeReelVideo.play();
    });

    // Toggle play/pause by clicking directly on the video
    nativeReelVideo.addEventListener('click', () => {
      if (nativeReelVideo.paused) {
        nativeReelVideo.play();
      } else {
        nativeReelVideo.pause();
      }
    });

    // Replay button: jump to start and play
    if (reelReplayBtn) {
      reelReplayBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        nativeReelVideo.currentTime = 0;
        nativeReelVideo.play();
      });
    }

    // Mute / Unmute toggle button
    if (reelMuteToggleBtn) {
      reelMuteToggleBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        nativeReelVideo.muted = !nativeReelVideo.muted;
        if (reelMuteIcon) {
          if (nativeReelVideo.muted) {
            // Muted SVG
            reelMuteIcon.innerHTML = '<path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27l4.73 4.73H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/>';
          } else {
            // Unmuted Sound SVG
            reelMuteIcon.innerHTML = '<path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>';
          }
        }
      });
    }
  }

  // 14. 4 Compact Box Reels Controller (New Arrivals Section)
  document.querySelectorAll('.reel-box-card').forEach(card => {
    const video = card.querySelector('.reel-box-video');
    const soundBtn = card.querySelector('.reel-sound-toggle');
    const wrap = card.querySelector('.reel-box-video-wrap');
    if (video) {
      video.muted = true;
      video.play().catch(() => {});
      if (soundBtn) {
        soundBtn.addEventListener('click', (e) => {
          e.stopPropagation();
          video.muted = !video.muted;
          soundBtn.classList.toggle('unmuted', !video.muted);
        });
      }
      if (wrap) {
        wrap.addEventListener('click', () => {
          if (video.paused) { video.play(); } else { video.pause(); }
        });
      }
    }
  });
});

