function "Webflow/Business Listing -> Webflow Payload" {
  input {
    json properties?
  }

  stack {
    api.lambda {
      code = """
        const item = $input.properties;
        
        // --- helper: warm ImageKit URL ---
        async function warmImageKit(url) {
          try {
            await fetch(url, { method: 'HEAD' });
          } catch (e) {
            console.warn(`Warm failed: ${url}`);
          }
        }
        
        // --- fallback (RAW, no ImageKit wrapping) ---
        const fallbackUrl = "https://cdn.prod.website-files.com/683a4969614808c01cd0d34f/685836d47b34dce1d54a4b97_Card%20Listing%20(empty)%20(1).avif";
        
        // --- build image URLs first ---
        const mainImageUrl = item.main_photo_url
          ? `https://ik.imagekit.io/manki32/tr:w-1600,q-85,f-avif/${item.main_photo_url}?tpl=xlarge`
          : fallbackUrl;
        
        const thumbnailUrl = item.main_photo_url
          ? `https://ik.imagekit.io/manki32/tr:w-800,q-85,f-avif/${item.main_photo_url}?tpl=xlarge`
          : fallbackUrl;
        
        const ogImageUrl = item.main_photo_url
          ? `https://ik.imagekit.io/manki32/tr:w-1600,h-945,fo-auto,c-at_max,q-85,f-jpg/${item.main_photo_url}?tpl=xlarge`
          : fallbackUrl;
        
        // --- IMPORTANT: warm thumbnail before sending ---
        if (item.main_photo_url) {
          await warmImageKit(thumbnailUrl);
          await warmImageKit(ogImageUrl);
        }
        
        // --- editor text ---
        const editorJsText = item.editor_js_json?.blocks
          ?.map(block => block.data?.text)
          ?.join(' ') || '';
        
        // --- main data ---
        const data = {
          "alternative-title": '',
          "primary-listing": false,
          "status": false,
          "body-content": item.body_content,
          "text-summary": item.summary || editorJsText,
        
          "address-name": '',
          "address-street": item.address.street,
          "address-street-2": item.address.street2,
          "address-city": item.address.city,
          "address-state-province": item.address.region,
          "address-postal-code": item.address.postalCode,
          "address-country": 'US',
        
          "google-maps-latitude": item.latitude,
          "google-maps-longitude": item.longitude,
        
          // --- images ---
          "main-image": mainImageUrl,
          "main-image-title": '',
          "main-image-alt-text": '',
          "thumbnail-image": thumbnailUrl,
          "og-image": ogImageUrl,
        
          "crm-images": item.photo_urls
            ?.map(photo =>
              photo?.category !== 'main'
                ? `https://ik.imagekit.io/manki32/tr:w-1600,q-85,f-avif/${photo.url}?tpl=xlarge`
                : null
            )
            .filter(Boolean),
        
          // --- taxonomy ---
          "categories": item.tag_id?.map(tag => tag._category?.wf_id)?.filter(id => id != null),
          "highlight-tags": [...new Set(item.tag_id?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
          "regions": [...new Set(item.partner_regions?.map(item => item._places_regions?.Item_ID).filter(id => id != null && id.trim() !== ""))],
          "cities": [...new Set(item.partner_regions?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
        
          // --- contact ---
          "contact-phone": item.contact_phone,
          "contact-email": item.email,
          "contact-fax": '',
          "contact-opening-hours": item.working_hours,
          "contact-booking-url": '',
          "contact-website-url": item.website,
        
          // --- socials ---
          "social-facebook-url": item.facebook_url,
          "social-youtube-url": item.youtube_url,
          "social-twitter-url": item.twitter_url,
          "social-pinterest-url": item.pinterest_url,
          "social-tripadvisor-id": item.tripadvisor_id,
          "social-ticket-url": '',
          "social-instagram-url": item.instagram_url,
        
          // --- meta ---
          "search-term": '',
          "meta-title": item.meta_title,
          "meta-description": item.meta_description,
        
          // --- extras ---
          "amenities": item.amenities?.map(item => item.wf_id),
          "summary-rich": item.summary,
          "old-id": String(item.id),
        
          "name": item.title,
          "slug": item.slug?.toLowerCase()?.replace(/[^a-z0-9-]/g, '-')?.replace(/--+/g, '-')
        };
        
        // --- remove empty values ---
        const result = {};
        for (const key in data) {
          if (data[key]) {
            result[key] = data[key];
          }
        }
        
        // --- final payload ---
        const payload = {
          fieldData: result
        };
        
        return JSON.stringify(payload);
        """
      timeout = 10
    } as $x1
  }

  response = {x1: $x1}
}