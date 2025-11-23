import { buildItemsArray } from '$utils/buildItemsArray';
import { fetchAllCategories } from '$utils/fetchOps';

import type { SKU } from './data/sku';
import { skuMap } from './data/sku';

declare global {
  interface Window {
    turnstile_token?: string | undefined;
  }
  export interface Item {
    sku: SKU;
    quantity: number;
    unitOfMeasure: string;
  }
}

let items: Item[] = [];

if (window.location.pathname === '/plan/travel-guide') {
  const item = { sku: skuMap['ostg_quantity'], quantity: 1, unitOfMeasure: 'Each' };
  items.push(item);
}

window.Webflow ||= [];
window.Webflow.push(() => {
  const form = document.querySelector<HTMLFormElement>('[wized="map_order_form"]');
  const template = document.querySelector<HTMLDivElement>('[wized="category_item"]');
  const formSuccessElement = document.querySelector<HTMLDivElement>('[wized="order_map_success"]');
  const formErrorElement = document.querySelector<HTMLDivElement>('[wized="map_order_error"]');
  const formErrorMessageElement = document.querySelector<HTMLDivElement>(
    '[wized="order_error_text"]'
  );

  if (!form) {
    console.error('Form not found');
    return;
  }

  // Populate checkboxes using cloneNode
  async function formInputHandler() {
    try {
      if (!template) return;

      const categories = await fetchAllCategories();

      categories.forEach((cat) => {
        // clone the template
        const clone = template?.cloneNode(true) as HTMLLabelElement;
        const checkbox = clone.querySelector<HTMLInputElement>('input[type="checkbox"]');
        const label = clone.querySelector<HTMLSpanElement>('span');
        const checkboxParent = template?.parentElement as HTMLDivElement;

        if (checkbox && label) {
          checkbox.value = cat.id.toString();
          checkbox.id = `cat-${cat.id}`;
          clone.htmlFor = checkbox.id;
          label.textContent = cat.name;
        }

        clone.style.display = ''; // unhide
        checkboxParent.appendChild(clone);
      });

      template?.remove();
    } catch (err) {
      console.error('Error loading categories:', err);
    }
  }

  // Handle form submission
  async function formSubmitHandler(e: Event) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if (!form) return;

    const formData = new FormData(form);
    const interests = formData.getAll('interests');
    const company_name = formData.get('company_name');
    const isB2B = Boolean(company_name);

    if (window.location.pathname === '/arizona-guides-maps') {
      items = buildItemsArray(formData);
    }

    const btn = form.querySelector('input[type=submit]') as HTMLInputElement;

    const originalText = btn.value;

    btn.value = 'Submitting order...';
    btn.disabled = true;

    const payload = {
      first_name: formData.get('first_name'),
      last_name: formData.get('last_name'),
      email: formData.get('email'),
      interests,
      turnstile: window.turnstile_token || '',
      items,
      address: formData.get('address'),
      address2: formData.get('address2'),
      city: formData.get('city'),
      zip: formData.get('zip'),
      state: formData.get('state'),
      phone: formData.get('phone'),
      company_name,
      traveling_start_date: formData.get('traveling_start_date'),
      traveling_end_date: formData.get('traveling_end_date'),
      personalization: formData.get('personalization'),
      page_path: window.location.pathname,
      isB2B,
    };

    try {
      const res = await fetch('https://x7jb-b5dw-kwm6.n7e.xano.io/api:HpTMVO9N/order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (!res.ok) {
        const errorBody = await res.json();
        throw new Error(`Server error: ${errorBody.status} - ${errorBody.message}`);
      }

      const result = await res.json();
      console.log('Order submitted:', result);

      if (!formSuccessElement) {
        alert('Order submitted successfully!');
        return;
      }

      form.style.display = 'none';
      formSuccessElement.style.display = 'flex';
    } catch (err) {
      console.error('Submit failed:', err);

      if (!formErrorElement || !formErrorMessageElement) {
        alert('Form submission failed:' + err);
        return;
      }
      formErrorElement.style.display = 'flex';
      formErrorMessageElement.innerText = String(err);
    } finally {
      btn.value = originalText;
    }
  }

  // Init
  formInputHandler();
  form.addEventListener('submit', formSubmitHandler);
});

/* Todo: 
  - add loading state
  - push script to jsm
*/
