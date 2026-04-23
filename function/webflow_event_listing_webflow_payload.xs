function "Webflow/Event Listing -> Webflow Payload" {
  input {
    json properties?
  }

  stack {
    api.lambda {
      code = """
        const event = $input.properties;
        
        // --- helper: warm ImageKit URL ---
        async function warmImageKit(url) {
          try {
            await fetch(url, { method: 'HEAD' });
          } catch (e) {
            console.warn(`Warm failed: ${url}`);
          }
        }
        
        // --- helper: safe encode ---
        function encodeUrl(url) {
          return encodeURIComponent(url);
        }
        
        // --- fallback ---
        const fallbackUrl = "https://cdn.prod.website-files.com/683a4969614808c01cd0d34f/685836d47b34dce1d54a4b97_Card%20Listing%20(empty)%20(1).avif";
        
        // --- title case ---
        function toTitleCase(str) {
          return str.replace(
            /\w\S*/g,
            text => text.charAt(0).toUpperCase() + text.substring(1).toLowerCase()
          );
        }
        
        // --- frequency ---
        const freq = () => {
          if (event.freq) return '';
          if (event.freq === "SELECT_DATES") return '';
          return toTitleCase(String(event.freq));
        };
        
        // --- get main image ---
        const main_image_raw =
          event.photos?.find(photo => photo.category === 'main')?.url ||
          event.main_image?.url;
        
        // --- build ImageKit URLs (ENCODED) ---
        const mainImageUrl = main_image_raw
          ? `https://ik.imagekit.io/manki32/tr:w-1600,q-85,f-avif/${encodeUrl(main_image_raw)}?tpl=xlarge`
          : fallbackUrl;
        
        const thumbnailUrl = main_image_raw
          ? `https://ik.imagekit.io/manki32/tr:w-800,q-85,f-avif/${encodeUrl(main_image_raw)}?tpl=xlarge`
          : fallbackUrl;
        
        const ogImageUrl = main_image_raw
          ? `https://ik.imagekit.io/manki32/tr:w-1600,h-945,fo-auto,c-at_max,q-85,f-jpg/${encodeUrl(main_image_raw)}?tpl=xlarge`
          : fallbackUrl;
        
        // --- warm critical images (same as business listings) ---
        if (main_image_raw) {
          await warmImageKit(thumbnailUrl);
          await warmImageKit(ogImageUrl);
        }
        
        // --- data ---
        const data = {
          "post-date": event.post_date,
          "status": event.title,
          "date": event.start_date,
          "event-end-date": event.end_date,
          "all-day": event.all_day,
          "repeats": freq(),
          "capacity": "",
          "alternative-title": "",
          "body-content": event.description,
        
          "location-name": event.location_name,
          "address-name": event.address?.[0]?.name,
          "address-street-address": event.address?.[0]?.street,
          "address-street-address-2": event.address?.[0]?.street2,
          "address-city": event.address?.[0]?.city,
          "address-state-province": event.address?.[0]?.region,
          "address-postal-code": event.address?.[0]?.postalCode,
          "address-country": "US",
        
          "google-maps-latitude": event.latitude,
          "google-maps-longitude": event.longitude,
          "opening-hours": event.partner_hours,
          "event-admission": event.event_admission,
          "featured": event.featured,
        
          "categories": event.highlight_tags?.map(tag => tag._category?.wf_id)?.filter(id => id != null),
          "highlight-tags": [...new Set(event.highlight_tags?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
          "experiences": [...new Set(event.related_partners?.map(item => item.wf_item_id || null).filter(id => id != null && id.trim() !== ""))],
          "regions": [...new Set(event.partner_regions?.map(item => item._places_regions?.Item_ID).filter(id => id != null && id.trim() !== ""))],
          "cities-towns": [...new Set(event.partner_regions?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
        
          "search-term": "",
        
          "contact-name": event.contact_name,
          "contact-email": event.contact_email,
          "contact-phone": event.contact_phone,
        
          "social-facebook-url": event.facebook_url,
          "social-twitter-url": event.twitter_url,
          "social-website-url": event.web_url,
          "social-ticket-url": event.event_ticket_url,
          "social-youtube-url": event.partner_youtube_video_url,
        
          "contact-first-name-internal": event.contact_first_name_internal,
          "contact-last-name-internal": event.contact_last_name_internal,
          "contact-phone-internal": event.contact_phone_internal,
          "contact-email-internal": event.contact_email_internal,
        
          // --- CRM images ---
          "crm-images": event.photos
            ?.map(photo =>
              photo.category !== 'main'
                ? `https://ik.imagekit.io/manki32/tr:w-1600,q-85,f-avif/${encodeUrl(photo.url)}?tpl=xlarge`
                : null
            )
            .filter(Boolean),
        
          // --- images (NOW MATCH BUSINESS LOGIC) ---
          "main-image": mainImageUrl,
          "thumbnail-image": thumbnailUrl,
          "og-image": ogImageUrl,
        
          "main-image-title": "",
          "main-image-alt-text": "",
        
          "meta-title": "",
          "meta-description": "",
          "meta-keywords": "",
          "meta-image": "",
        
          "name": event.name,
          "slug": event.slug,
          "old-id": String(event.id),
        };
        
        // --- clean ---
        const result = {};
        for (const key in data) {
          if (data[key]) {
            result[key] = data[key];
          }
        }
        
        return JSON.stringify({
          fieldData: result
        });
        """
      timeout = 20
    } as $x1
  }

  response = $x1
}