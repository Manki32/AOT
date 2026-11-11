// create or edit business
query business verb=POST {
  api_group = "Default"
  auth = "user"

  input {
    dblink {
      table = "business_listing"
      override = {
        slug               : {hidden: true}
        email              : {hidden: true}
        hs_id              : {hidden: true}
        title              : {hidden: false}
        status             : {hidden: true}
        tag_id             : {hidden: true}
        address            : {hidden: false}
        old_ids            : {hidden: true}
        old_url            : {hidden: true}
        summary            : {hidden: true}
        temp_id            : {hidden: true}
        user_id            : {hidden: true}
        website            : {hidden: false}
        wf_fail            : {hidden: true}
        draft_id           : {hidden: true}
        latitude           : {hidden: false}
        owner_id           : {hidden: true}
        amenities          : {hidden: false}
        longitude          : {hidden: false}
        post_date          : {hidden: true}
        created_at         : {hidden: true}
        hero_image         : {hidden: true}
        meta_image         : {hidden: true}
        meta_title         : {hidden: true}
        photo_urls         : {hidden: true}
        wf_item_id         : {hidden: true}
        category_id        : {hidden: true}
        more_images        : {hidden: true}
        revision_id        : {hidden: true}
        twitter_url        : {hidden: false}
        youtube_url        : {hidden: false}
        body_content       : {hidden: true, required: true}
        date_updated       : {hidden: true}
        facebook_url       : {hidden: false}
        last_edit_by       : {hidden: true}
        contact_phone      : {hidden: false}
        instagram_url      : {hidden: false}
        meta_keywords      : {hidden: true}
        missing_email      : {hidden: true}
        pinterest_url      : {hidden: false}
        s3_meta_image      : {hidden: true}
        working_hours      : {hidden: false}
        main_photo_url     : {hidden: true}
        push_to_wf_cms     : {hidden: true}
        tripadvisor_id     : {hidden: false}
        partner_regions    : {hidden: true}
        meta_description   : {hidden: true}
        provisional_draft  : {hidden: false}
        partner_search_term: {hidden: true}
      }
    }
  
    // Declared as plain text (not the table's `email` type) so an unfinished
    // address can still be saved on a draft. Format is validated below on submit.
    text email? filters=trim|lower
  
    int? business_listing_id?=0 {
      table = "business_listing"
    }
  
    text[] images_to_keep? filters=trim
    file? main_image?
    file[]? extra_images?
    text main_image_url? filters=trim
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    conditional {
      if (($input.business_listing_id|is_empty) == false) {
        db.get business_listing {
          field_name = "id"
          field_value = $input.business_listing_id
        } as $business_listing
      
        precondition (($business_listing.status|equals:"Requesting Approval") == false || $user1.role == "Admin") {
          error = "You can't edit a business that is currently awaiting an approval response."
        }
      
        api.lambda {
          code = """
            const business_listing = $var.business_listing;
            const auth_id = $auth.id;
            
            // Check if business_listing exists and if user_id is an array
            if (business_listing && Array.isArray(business_listing.user_id)) {
                // Use the .includes() method to check if auth_id is in the array
                return business_listing.user_id.includes(auth_id);
            }
            
            // If the checks fail, return false by default
            return false;
            """
          timeout = 10
        } as $user_id_list_contains_user
      
        precondition ($user_id_list_contains_user || $user1.role == "Admin") {
          error = "You don't have permission to edit this business."
        }
      
        !precondition (($business_listing.status|equals:"Approved") == false) {
          error = "You can't edit a business that was already approved."
        }
      
        // Duplicate title check (skipped for untitled drafts; archived listings don't count)
        conditional {
          if (($input.title|is_empty) == false) {
            db.query business_listing {
              where = $db.business_listing.id != $input.business_listing_id && $db.business_listing.title == $input.title && $db.business_listing.status != "Archived"
              return = {type: "list"}
            } as $business_listing_title_repited
          
            precondition ($business_listing_title_repited|is_empty) {
              error_type = "inputerror"
              error = '{"message":"A business listing with that name already exists.","fields":{"title":"A business listing with that name already exists. Choose a different name."}}'
            }
          }
        }
      }
    
      else {
        var $business_listing {
          value = null
        }
      
        var.update $business_listing.user_id {
          value = []|push:$auth.id|unique:""
        }
      
        // Duplicate title check (skipped for untitled drafts; archived listings don't count)
        conditional {
          if (($input.title|is_empty) == false) {
            db.query business_listing {
              where = $db.business_listing.title == $input.title && $db.business_listing.status != "Archived"
              return = {type: "list"}
            } as $business_listing_title_repited
          
            precondition ($business_listing_title_repited|is_empty) {
              error_type = "inputerror"
              error = '{"message":"A business listing with that name already exists.","fields":{"title":"A business listing with that name already exists. Choose a different name."}}'
            }
          }
        }
      }
    }
  
    // Field-level validation. Drafts are never validated here (they always save).
    // On submit, returns null when everything is valid, otherwise a JSON string:
    //   {"message": "...", "fields": {"<input name>": "<message>", ...}}
    // The front end parses `fields` and highlights each input. Keep the rules in
    // sync with the Wized function `businessForm_module`.
    api.lambda {
      code = """
        const isDraft = $input.provisional_draft === true;
        if (isDraft) return null;
        
        const str = (v) => (v === null || v === undefined) ? "" : String(v).trim();
        const fields = {};
        
        const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        const phoneRegex = /^(\+1\s?)?(\(?[2-9][0-9]{2}\)?)[\s.-]?([2-9][0-9]{2})[\s.-]?([0-9]{4})$/;
        
        // http(s) URL with a real hostname, or null
        function parseHttpUrl(value) {
          try {
            const u = new URL(value);
            if (u.protocol !== "http:" && u.protocol !== "https:") return null;
            if (!/^[a-z0-9.-]+\.[a-z]{2,}$/i.test(u.hostname)) return null;
            return u;
          } catch (e) {
            return null;
          }
        }
        function hostMatches(hostname, domains) {
          const h = hostname.toLowerCase().replace(/^www\./, "");
          return domains.some((d) => h === d || h.endsWith("." + d));
        }
        
        // Title
        if (!str($input.title)) fields.title = "Enter your business name.";
        
        // Description (Editor.js JSON): at least one block with visible text
        let blocks = [];
        try {
          let ej = $input.editor_js_json;
          if (typeof ej === "string") ej = JSON.parse(ej);
          if (ej && Array.isArray(ej.blocks)) blocks = ej.blocks;
        } catch (e) {
          blocks = [];
        }
        const hasDescription = blocks.some((b) => {
          const d = b && b.data ? b.data : {};
          if (typeof d.text === "string" && str(d.text.replace(/<[^>]*>/g, "").replace(/&nbsp;/g, " "))) return true;
          if (Array.isArray(d.items) && d.items.length > 0) return true;
          return false;
        });
        if (!hasDescription) fields.editor_js_json = "Add a description of your business.";
        
        // Amenities (arrives as an array, or as a JSON string from multipart)
        let amenities = $input.amenities;
        if (typeof amenities === "string") {
          try { amenities = JSON.parse(amenities); } catch (e) { amenities = []; }
        }
        if (!Array.isArray(amenities) || amenities.length === 0) fields.amenities = "Select at least one amenity.";
        
        // Working hours
        if (!str($input.working_hours)) fields.working_hours = "Enter your working hours.";
        
        // Address: text plus the coordinates set by the Google Places pick
        if (!str($input.address_string) || !str($input.latitude) || !str($input.longitude)) {
          fields.address = "Select your address from the suggestions list.";
        }
        
        // Cover image: a new upload, or an existing (non-blob) URL
        const mainUrl = str($input.main_image_url);
        const hasMainImage = !!$input.main_image || (mainUrl !== "" && !mainUrl.startsWith("blob:"));
        if (!hasMainImage) fields.main_image = "Upload a cover image.";
        
        // Phone (US)
        const phone = str($input.contact_phone);
        if (!phone) fields.contact_phone = "Enter a phone number.";
        else if (!phoneRegex.test(phone)) fields.contact_phone = "Enter a valid US phone number, e.g. (602) 555-0123.";
        
        // Email
        const email = str($input.email).toLowerCase();
        if (!email) fields.email = "Enter a business email address.";
        else if (!emailRegex.test(email)) fields.email = "Enter a valid email address.";
        
        // Website
        const website = str($input.website);
        if (!website) fields.website = "Enter your website address.";
        else if (!parseHttpUrl(website)) fields.website = "Enter a full web address starting with https://";
        
        // Optional social links: must be a URL on the right site when filled in
        const socials = [
          ["facebook_url",  $input.facebook_url,  ["facebook.com", "fb.com"],  "Facebook"],
          ["instagram_url", $input.instagram_url, ["instagram.com"],           "Instagram"],
          ["twitter_url",   $input.twitter_url,   ["twitter.com", "x.com"],    "X (Twitter)"],
          ["youtube_url",   $input.youtube_url,   ["youtube.com", "youtu.be"], "YouTube"],
          ["pinterest_url", $input.pinterest_url, null,                        "Pinterest"]
        ];
        for (const [key, raw, domains, label] of socials) {
          const value = str(raw);
          if (!value) continue;
          const u = parseHttpUrl(value);
          if (!u) {
            fields[key] = `Enter a full ${label} link starting with https://`;
            continue;
          }
          if (domains && !hostMatches(u.hostname, domains)) {
            fields[key] = `This doesn't look like a ${label} link (expected ${domains.join(" or ")}).`;
          }
          if (!domains && !/(^|\.)pinterest\.[a-z.]+$/i.test(u.hostname.replace(/^www\./, ""))) {
            fields[key] = `This doesn't look like a ${label} link.`;
          }
        }
        
        const count = Object.keys(fields).length;
        if (count === 0) return null;
        return JSON.stringify({
          message: count === 1 ? "Please fix the highlighted field." : `Please fix the ${count} highlighted fields.`,
          fields
        });
        """
      timeout = 10
    } as $field_errors
  
    precondition ($field_errors == null) {
      error_type = "inputerror"
      error = $field_errors
    }
  
    conditional {
      if ($input.provisional_draft) {
        var $status {
          value = "Draft"
        }
      }
    
      else {
        var $status {
          value = "Requesting Approval"
        }
      }
    }
  
    // Main Image Conditional
    conditional {
      if (($input.main_image|is_empty) == false) {
        storage.create_image {
          value = $input.main_image
          access = "public"
          filename = ""
        } as $main_image
      
        var $main_image_url {
          value = "https://x7jb-b5dw-kwm6.n7e.xano.io"|concat:$main_image.path:""
        }
      }
    
      else {
        var $main_image {
          value = null
        }
      }
    }
  
    conditional {
      if (($input.main_image_url|is_empty) == false) {
        var $main_image_url {
          value = $input.main_image_url
        }
      }
    }
  
    // More Images Conditional
    conditional {
      if (($input.extra_images|is_empty) == false) {
        var $extra_images {
          value = []
        }
      
        foreach ($input.extra_images) {
          each as $image {
            storage.create_image {
              value = $image
              access = "public"
              filename = ""
            } as $single_image
          
            array.push $extra_images {
              value = $single_image
            }
          }
        }
      }
    
      else {
        var $extra_images {
          value = []
        }
      }
    }
  
    conditional {
      if (($input.business_listing_id|is_empty) == false) {
        array.filter ($business_listing.photo_urls) if ($this.url|in:$input.images_to_keep) as $images_to_keep_in_business
        foreach ($extra_images) {
          each as $single_image {
            array.push $images_to_keep_in_business {
              value = {}
                |set:"url":("https://x7jb-b5dw-kwm6.n7e.xano.io"|concat:$single_image.path:"")
                |set:"index":0
                |set:"category":""
                |set:"alt":""
                |set:"title":""
            }
          }
        }
      }
    
      else {
        var $images_to_keep_in_business {
          value = []
        }
      
        foreach ($extra_images) {
          each as $single_image {
            array.push $images_to_keep_in_business {
              value = {}
                |set:"url":("https://x7jb-b5dw-kwm6.n7e.xano.io"|concat:$single_image.path:"")
                |set:"index":0
                |set:"category":""
                |set:"alt":""
                |set:"title":""
            }
          }
        }
      }
    }
  
    // Editor.js JSON -> HTML for body_content. Tolerates a string, a missing
    // `blocks` array or malformed JSON (returns "" instead of failing).
    api.lambda {
      code = """
        function editorJsToHtml(editorJson) {
          const blocks = (editorJson && Array.isArray(editorJson.blocks)) ? editorJson.blocks : [];
          let html = '';
        
          blocks.forEach(block => {
            const { type, data } = block || {};
            if (!data) return;
        
            switch (type) {
              case 'header':
                const level = Math.min(Math.max(Number(data.level) || 4, 1), 6); // clamp between 1 and 6
                html += `<h${level}>${data.text ?? ''}</h${level}>\n`;
                break;
        
              case 'paragraph':
                html += `<p>${data.text ?? ''}</p>\n`;
                break;
        
              // Add more block types here as needed (e.g., list, image, quote, etc.)
        
              default:
                console.warn(`Unsupported block type: ${type}`);
                break;
            }
          });
        
          return html;
        }
        
        let editorJson = $input.editor_js_json;
        if (typeof editorJson === "string") {
          try { editorJson = JSON.parse(editorJson); } catch (e) { editorJson = null; }
        }
        
        return editorJsToHtml(editorJson);
        """
      timeout = 10
    } as $editor_js_html
  
    var $amenities {
      value = $input.amenities|safe_array
    }
  
    db.add_or_edit business_listing {
      field_name = "id"
      field_value = $business_listing|get:"id":0
      enforce_hidden_fields = false
      data = {
        title            : $input.title
        user_id          : $business_listing.user_id
        body_content     : $editor_js_html
        editor_js_json   : $input.editor_js_json
        wf_synced        : $input.wf_synced
        amenities        : $amenities
        working_hours    : $input.working_hours
        website          : $input.website
        email            : $input.email
        main_photo_url   : $main_image_url
        address_string   : $input.address_string
        latitude         : $input.latitude
        longitude        : $input.longitude
        status           : $status
        facebook_url     : $input.facebook_url
        youtube_url      : $input.youtube_url
        twitter_url      : $input.twitter_url
        instagram_url    : $input.instagram_url
        pinterest_url    : $input.pinterest_url
        tripadvisor_id   : $input.tripadvisor_id
        provisional_draft: $input.provisional_draft
        contact_phone    : $input.contact_phone
        address          : $input.address
        hero_image       : $main_image
        more_images      : $extra_images
        photo_urls       : $images_to_keep_in_business
      }
    } as $business_listing
  }

  response = $business_listing
  tags = ["new"]
}