// create or edit business
query business verb=POST {
  api_group = "Default"
  auth = "user"

  input {
    dblink {
      table = "business_listing"
      override = {
        slug               : {hidden: true}
        hs_id              : {hidden: true}
        status             : {hidden: true}
        tag_id             : {hidden: true}
        old_ids            : {hidden: true}
        old_url            : {hidden: true}
        summary            : {hidden: true}
        temp_id            : {hidden: true}
        user_id            : {hidden: true}
        wf_fail            : {hidden: true}
        draft_id           : {hidden: true}
        owner_id           : {hidden: true}
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
        body_content       : {hidden: true}
        date_updated       : {hidden: true}
        last_edit_by       : {hidden: true}
        meta_keywords      : {hidden: true}
        missing_email      : {hidden: true}
        s3_meta_image      : {hidden: true}
        main_photo_url     : {hidden: true}
        push_to_wf_cms     : {hidden: true}
        partner_regions    : {hidden: true}
        meta_description   : {hidden: true}
        partner_search_term: {hidden: true}
      }
    }
  
    int? business_listing_id? {
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
      
        db.query business_listing {
          where = $db.business_listing.id != $input.business_listing_id && $db.business_listing.title == $input.title
          return = {type: "list"}
        } as $business_listing_title_repited
      
        precondition ($business_listing_title_repited|is_empty) {
          error = "A business listing with that name already exists."
        }
      }
    
      else {
        var $business_listing {
          value = null
        }
      
        var.update $business_listing.user_id {
          value = []|push:$auth.id|unique:""
        }
      
        db.query business_listing {
          where = $db.business_listing.title == $input.title
          return = {type: "list"}
        } as $business_listing_title_repited
      
        precondition ($business_listing_title_repited|is_empty) {
          error = "A business listing with that name already exists."
        }
      }
    }
  
    api.lambda {
      code = """
        const data = {
          email: $input.email,
          title: $input.title,
          website: $input.website,
          latitude: $input.latitude,
          longitude: $input.longitude,
          address_string: $input.address_string,
          main_image: $input.main_image,
          main_image_url: $input.main_image_url,
          contact_phone: $input.contact_phone,
          editor_js_json: $input.editor_js_json,
          provisional_draft: $input.provisional_draft
        };
        
        // Si el main_image_url contiene "blob:", se vuelve null
        if (typeof data.main_image_url === "string" && data.main_image_url.includes("blob:")) {
          data.main_image_url = null;
        }
        
        // Si es borrador, siempre es válido
        if (data.provisional_draft === true) {
          return true;
        } else {
          const hasEmail = !!data.email?.trim();
          const hasTitle = !!data.title?.trim();
          const hasLatitude = !!data.latitude;
          const hasLongitude = !!data.longitude;
          const hasWebsite = !!data.website?.trim();
        
          const hasAddress = !!data.address_string?.trim();
          const hasMainImage = !!(data.main_image || data.main_image_url);
        
          const hasPhone = !!data.contact_phone?.trim();
        
          let editorHasBlocks = false;
          try {
            let editor = {};
            if (typeof data.editor_js_json === "string") {
              editor = JSON.parse(data.editor_js_json);
            } else if (typeof data.editor_js_json === "object" && data.editor_js_json !== null) {
              editor = data.editor_js_json;
            }
            editorHasBlocks = Array.isArray(editor.blocks) && editor.blocks.length > 0;
          } catch (e) {
            editorHasBlocks = false;
          }
        
          return (
            hasEmail &&
            hasTitle &&
            hasLatitude &&
            hasLongitude &&
            hasWebsite &&
            hasAddress &&
            hasMainImage &&
            hasPhone &&
            editorHasBlocks
          );
        }
        """
      timeout = 10
    } as $pass_preconditions
  
    precondition ($pass_preconditions || $user1.id == "Admin") {
      error_type = "inputerror"
      error = """
        Please fill out all required fields to submit your business for approval.
        """
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
      
        api.lambda {
          code = """
            let error = null;
            
            // --- Expresiones regulares ---
            const emailRegex = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
            
            const phoneRegex = new RegExp(/^(\+1\s?)?(\(?[2-9][0-9]{2}\)?)[\s.-]?([2-9][0-9]{2})[\s.-]?([0-9]{4})$/);
            
            const urlRegex = new RegExp(/^(https?|ftp):\/\/((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/, 'i');
            
            // --- Campos de entrada ---
            const email = $input.email;
            const phone = $input.contact_phone;
            const website = $input.website;
            const twitter_url = $input.twitter_url;
            const facebook_url = $input.facebook_url;
            const linkedin_url = $input.linkedin_url;
            const instagram_url = $input.instagram_url;
            
            // --- Validaciones principales ---
            
            // 1. Email (obligatorio)
            if (!email || !emailRegex.test(String(email).toLowerCase())) {
                error = "A valid email address is required.";
            }
            
            // 2. Teléfono de EE.UU. (obligatorio)
            if (!error && (!phone || !phoneRegex.test(String(phone)))) {
                error = "A valid US phone number is required.";
            }
            
            // --- Funciones auxiliares ---
            
            // Validar URL opcional
            function validateOptionalUrl(value, fieldName) {
                if (value && String(value).trim() !== '') {
                    if (!urlRegex.test(String(value))) {
                        error = `Please provide a valid URL for ${fieldName}.`;
                    }
                }
            }
            
            // Validar URL de red social con dominios permitidos
            function validateSocialUrl(value, validDomains, platformName) {
                if (value && String(value).trim() !== '') {
                    if (!urlRegex.test(String(value))) {
                        error = `Please provide a valid URL for ${platformName}.`;
                        return;
                    }
            
                    try {
                        const urlObj = new URL(value);
                        const hostname = urlObj.hostname.replace(/^www\./, '').toLowerCase();
            
                        const isValidDomain = validDomains.some(domain => hostname === domain);
                        if (!isValidDomain) {
                            error = `The ${platformName} URL must be from ${validDomains.join(" or ")}.`;
                        }
                    } catch {
                        error = `Invalid format for ${platformName} URL.`;
                    }
                }
            }
            
            // --- Validaciones opcionales de URLs ---
            if (!error) validateOptionalUrl(website, 'your website');
            if (!error) validateSocialUrl(twitter_url, ['twitter.com', 'x.com'], 'Twitter');
            if (!error) validateSocialUrl(facebook_url, ['facebook.com'], 'Facebook');
            if (!error) validateSocialUrl(linkedin_url, ['linkedin.com'], 'LinkedIn');
            if (!error) validateSocialUrl(instagram_url, ['instagram.com'], 'Instagram');
            
            // --- Resultado final ---
            return error;
            """
          timeout = 10
        } as $error
      
        precondition ($var.error == null) {
          error_type = "inputerror"
          error = $var.error
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
  
    api.lambda {
      code = """
        function editorJsToHtml(editorJson) {
          const blocks = editorJson.blocks;
          let html = '';
        
          blocks.forEach(block => {
            const { type, data } = block;
        
            switch (type) {
              case 'header':
                const level = Math.min(Math.max(data.level, 1), 6); // clamp between 1 and 6
                html += `<h${level}>${data.text}</h${level}>\n`;
                break;
        
              case 'paragraph':
                html += `<p>${data.text}</p>\n`;
                break;
        
              // Add more block types here as needed (e.g., list, image, quote, etc.)
        
              default:
                console.warn(`Unsupported block type: ${type}`);
                break;
            }
          });
        
          return html;
        }
        
        // Example usage:
        const editorJson = $input.editor_js_json;
        
        const htmlOutput = editorJsToHtml(editorJson);
        return htmlOutput;
        """
      timeout = 10
    } as $editor_js_html
  
    var $amenities {
      value = $input.amenities|safe_array
    }
  
    db.add_or_edit business_listing {
      field_name = "id"
      field_value = $business_listing|get:"id":0
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