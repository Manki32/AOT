// create or edit business
query event verb=POST {
  api_group = "Default"
  auth = "user"

  input {
    text event_name? filters=trim
    text frequency? filters=trim
    text contact_phone? filters=trim
    text website? filters=trim
    text email? filters=trim
    text facebook? filters=trim
    text instagram? filters=trim
    text youtube? filters=trim
    text pinterest? filters=trim
    text x_link? filters=trim
    int event_id?
    bool provisional_draft?
    file? main_image?
    file[]? extra_images?
    text[] images_to_keep? filters=trim
    json editor_js_json?
    text latitude? filters=trim
    text longitude? filters=trim
    text address_string? filters=trim
    text main_image_url? filters=trim
    text tripadvisor_id? filters=trim
    text date_from? filters=trim
    text date_to? filters=trim
    json address?
    text date_until? filters=trim
  }

  stack {
    var $event {
      value = {}
    }
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    conditional {
      if (($input.event_id|is_empty) == false) {
        db.get event {
          field_name = "id"
          field_value = $input.event_id
        } as $event
      
        api.lambda {
          code = """
            const event_listing = $var.event;
            const auth_id = $auth.id;
            
            // Check if event_listing exists and if user_id is an array
            if (event_listing && Array.isArray(event_listing.user_id)) {
                // Use the .includes() method to check if auth_id is in the array
                return event_listing.user_id.includes(auth_id);
            }
            
            // If the checks fail, return false by default
            return false;
            """
          timeout = 10
        } as $user_id_list_contains_user
      
        precondition ($user_id_list_contains_user || $user1.role == "Admin") {
          error = "You don't have permission to edit this business."
        }
      
        precondition ($event.status != "Requesting approval") {
          error = "You can't edit an event that is currently awaiting an approval response."
        }
      
        !precondition ($event.status != "Approved") {
          error = "You can't edit an event that was already approved."
        }
      
        !db.query event {
          where = $db.event.id != $input.event_id && $db.event.name == $input.event_name
          return = {type: "list"}
        } as $event_name_repeated
      
        !precondition ($event_name_repeated|is_empty) {
          error = "An event listing with that name already exists."
        }
      }
    
      else {
        !db.query event {
          where = $db.event.name == $input.event_name
          return = {type: "list"}
        } as $event_name_repeated
      
        var.update $event.user_id {
          value = []|push:$auth.id|unique:""
        }
      
        !precondition ($event_name_repeated|is_empty) {
          error = "An event listing with that name already exists."
        }
      }
    }
  
    api.lambda {
      code = """
        const data = {...$input}
        
        if (typeof data.main_image_url === "string" && data.main_image_url.includes("blob:")) {
          data.main_image_url = null;
        }
        
        if (data.provisional_draft === true) {
          return true;
        }
        
        const hasEventName = !!data.event_name?.trim();
        const hasDateFrom = !!data.date_from?.trim();
        const hasDateTo = !!data.date_to?.trim();
        const hasEmail = !!data.email?.trim();
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
          hasEventName &&
          hasDateFrom &&
          hasDateTo &&
          hasEmail &&
          hasMainImage &&
          hasPhone &&
          editorHasBlocks
        );
        """
      timeout = 10
    } as $pass_preconditions
  
    precondition ($pass_preconditions || $user1.role == "Admin") {
      error_type = "inputerror"
      error = "Please fill out all required fields to submit your event for approval."
    }
  
    conditional {
      if ($input.provisional_draft) {
        var $status {
          value = "Draft"
        }
      }
    
      else {
        var $status {
          value = "Requesting approval"
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
            const twitter_url = $input.x_link;
            const facebook_url = $input.facebook;
            const youtube_url = $input.youtube;
            const instagram_url = $input.instagram;
            const pinterest_url = $input.pinterest;
            
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
            if (!error) validateSocialUrl(youtube_url, ['youtube.com', 'youtu.be'], 'Youtube');
            if (!error) validateSocialUrl(instagram_url, ['instagram.com'], 'Instagram');
            if (!error) validateSocialUrl(pinterest_url, ['pinterest.com'], 'Pinterest');
            
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
      if (($input.event_id|is_empty) == false) {
        array.filter ($event.photos) if ($this.url|in:$input.images_to_keep) as $images_to_keep_in_event
        foreach ($extra_images) {
          each as $single_image {
            array.push $images_to_keep_in_event {
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
        var $images_to_keep_in_event {
          value = []
        }
      
        foreach ($extra_images) {
          each as $single_image {
            array.push $images_to_keep_in_event {
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
  
    api.lambda {
      code = """
        const toTimestamp = (dateString) => {
            if (!dateString) {
                return null;
            }
            const dateObject = new Date(dateString);
            if (isNaN(dateObject.getTime())) {
                return null;
            }
            return dateObject.getTime();
        };
        
        const fromTimestamp = toTimestamp($input.date_from);
        const toTimestampResult = toTimestamp($input.date_to);
        
        return {
            'from': fromTimestamp,
            'to': toTimestampResult
        };
        """
      timeout = 10
    } as $timestamps
  
    db.add_or_edit event {
      field_name = "id"
      field_value = $event|get:"id":0
      data = {
        name                     : $input.event_name
        description              : $editor_js_html
        latitude                 : $input.latitude
        longitude                : $input.longitude
        contact_email            : $input.email
        user_id                  : $event.user_id
        web_url                  : $input.website
        facebook_url             : $input.facebook
        x_url                    : $input.x_link
        private_email            : $input.email
        status                   : $status
        post_date                : now
        start_date               : $input.date_from
        end_date                 : $input.date_to
        freq                     : $input.frequency
        is_provisional_draft     : $input.provisional_draft
        url                      : $input.website
        location_name            : $input.address_string
        contact_phone            : $input.contact_phone
        partner_youtube_video_url: $input.youtube
        main_image_url           : $main_image_url
        instagram_url            : $input.instagram
        pinterest_url            : $input.pinterest
        tripadvisor_id           : $input.tripadvisor_id
        editor_js_json           : $input.editor_js_json
        main_image               : $main_image
        more_images              : $extra_images
        photos                   : $images_to_keep_in_event
        address                  : []|push:$input.address
      }
    } as $event
  }

  response = $event
  tags = ["new"]
}