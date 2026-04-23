function "Webflow/Webflow -> Create All Business Listings" {
  input {
    object paging {
      schema {
        int items?=5
        int page_nr?=1
      }
    }
  }

  stack {
    group {
      stack {
        var $items_to_create {
          value = []
        }
      
        var $patched_items {
          value = []
        }
      
        var $page {
          value = $input.paging.page_nr
        }
      
        var $continue_loop {
          value = true
        }
      
        !while ($continue_loop) {
          each {
            db.query business_listing {
              return = {
                type  : "list"
                paging: {page: $page, per_page: $input.paging.items}
              }
            
              addon = [
                {
                  name : "tag_item"
                  input: {tag_id: $output.$this}
                  addon: [
                    {
                      name : "category"
                      input: {category_id: $output.category_id}
                      as   : "_category"
                    }
                  ]
                  as   : "items.tag_id"
                }
                {
                  name : "amenity_1"
                  input: {amenity_id: $output.$this}
                  as   : "items.amenities"
                }
                {
                  name  : "places_cities_and_towns"
                  output: ["id", "level", "parent", "wf_id"]
                  input : {places_cities_and_towns_id: $output.$this}
                  addon : [
                    {
                      name  : "places_regions"
                      output: ["Item_ID"]
                      input : {places_regions_id: $output.region_id}
                      as    : "_places_regions"
                    }
                  ]
                  as    : "items.partner_regions"
                }
                {
                  name : "s3_images"
                  input: {s3_images_id: $output.s3_meta_image}
                  as   : "items._s3_images"
                }
              ]
            } as $items
          
            foreach ($items.items) {
              each as $item {
                api.lambda {
                  code = """
                    
                    const result = {
                      fieldData: {
                        "alternative-title": '',
                        "primary-listing": false,
                        "status": false,
                        "body-content": $var.item.body_content,
                        "text-summary": $var.item.summary,
                        "address-name": '',
                        "address-street": $var.item.address.street,
                        "address-street-2": $var.item.address.street2,
                        "address-city": $var.item.address.city,
                        "address-state-province": $var.item.address.region,
                        "address-postal-code": $var.item.address.postalCode,
                        "address-country": 'US',
                        "google-maps-latitude": $var.item.latitude,
                        "google-maps-longitude": $var.item.longitude,
                        "main-image": $var.item.main_image,
                        "main-image-title": '',
                        "main-image-alt-text": '',
                        "crm-images": $var.item.photos?.map(image => image.url),
                        "categories": $var.item.tag_id?.map(tag => tag._category?.wf_id)?.filter(id => id != null),
                       "highlight-tags": [...new Set($var.item.tag_id?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
                        "regions": [...new Set($var.item.partner_regions?.map(item => item._places_regions?.Item_ID).filter(id => id != null && id.trim() !== ""))],
                        "cities": [...new Set($var.item.partner_regions?.map(item => item?.wf_id).filter(id => id != null && id.trim() !== ""))],
                        "contact-phone": $var.item.contact_phone,
                        "contact-email": $var.item.email,
                        "contact-fax": '',
                        "contact-opening-hours": $var.item.working_hours,
                        "contact-booking-url": '',
                        "contact-website-url": $var.item.website,
                        "social-facebook-url": $var.item.facebook_url,
                        "social-youtube-url": $var.item.youtube_url,
                        "social-twitter-url": $var.item.twitter_url,
                        "social-pinterest-url": $var.item.pinterest_url,
                        "social-tripadvisor-id": $var.item.tripadvisor_id,
                        "social-ticket-url": '',
                        "search-term": '',
                        "meta-title": $var.item.meta_title,
                        "meta-description": $var.item.meta_description,
                        "amenities": $var.item.amenities?.map(item => item.wf_id),
                        "summary-rich": $var.item.summary,
                        "social-instagram-url": $var.item.instagram_url,
                        "old-id": String($var.item.id),
                        "name": $var.item.title,
                        "slug": $var.item.slug?.toLowerCase()?.replace(/[^a-z0-9-]/g, '-')?.replace(/--+/g, '-')
                      }
                    } 
                    
                    return result
                    """
                  timeout = 10
                } as $x1
              
                debug.log {
                  value = $x1
                }
              
                !api.request {
                  url = "https://api.webflow.com/v2/collections/684c0a9306c23f7bb7c088cf/items"
                  method = "POST"
                  params = $x1|!set:"items":$items_to_create
                  headers = []
                    |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
                    |push:"Content-Type: application/json"
                  timeout = 20
                } as $api_item
              
                array.push $items_to_create {
                  value = $x1
                }
              
                !conditional {
                  if ($api_item.response.status == 202) {
                    db.patch business_listing_raw_data {
                      field_name = "id"
                      field_value = $item.id
                      data = {}
                        |set:"wf_item_id":$api_item.response.result.id
                        |set:"wf_fail":false
                    } as $business_listing1
                  
                    array.push $patched_items {
                      value = $business_listing1
                    }
                  }
                
                  else {
                    db.patch business_listing_raw_data {
                      field_name = "id"
                      field_value = $item.id
                      data = {}|set:"wf_fail":true
                    } as $business_listing2
                  }
                }
              }
            }
          
            conditional {
              if ($items.nextPage != true) {
                var.update $continue_loop {
                  value = false
                }
              }
            
              else {
                var.update $page {
                  value = $items.nextPage
                }
              }
            }
          
            api.request {
              url = "https://api.webflow.com/v2/collections/683a4969614808c01cd0d41f/items"
              method = "POST"
              params = {}|set:"items":$items_to_create
              headers = []
                |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
                |push:"Content-Type: application/json"
              timeout = 60
            } as $api1
          
            conditional {
              if ($api1.response.status == 202) {
                foreach ($api1.response.result.items) {
                  each as $wf_item {
                    !db.patch business_listing_raw_data {
                      field_name = "id"
                      field_value = $wf_item.fieldData["old-id"]
                      data = {}|set:"wf_item_id":$wf_item.id
                    } as $business_listing1
                  
                    db.patch business_listing {
                      field_name = "id"
                      field_value = $wf_item.fieldData["old-id"]
                      data = {}|set:"wf_item_id":$wf_item.id
                      output = ["id", "slug", "wf_item_id"]
                    } as $business_listing_cleanup1
                  
                    array.push $patched_items {
                      value = $business_listing_cleanup1
                    }
                  }
                }
              }
            
              else {
                !break
              }
            }
          }
        }
      
        db.query business_listing {
          where = $db.business_listing.wf_synced == false
          return = {
            type  : "list"
            paging: {page: $page, per_page: $input.paging.items}
          }
        
          addon = [
            {
              name : "tag_item"
              input: {tag_id: $output.$this}
              addon: [
                {
                  name : "category"
                  input: {category_id: $output.category_id}
                  as   : "_category"
                }
              ]
              as   : "items.tag_id"
            }
            {
              name : "amenity_1"
              input: {amenity_id: $output.$this}
              as   : "items.amenities"
            }
            {
              name  : "places_cities_and_towns"
              output: ["id", "level", "parent", "wf_id"]
              input : {places_cities_and_towns_id: $output.$this}
              addon : [
                {
                  name  : "places_regions"
                  output: ["Item_ID"]
                  input : {places_regions_id: $output.region_id}
                  as    : "_places_regions"
                }
              ]
              as    : "items.partner_regions"
            }
            {
              name : "s3_images"
              input: {s3_images_id: $output.s3_meta_image}
              as   : "items._s3_images"
            }
          ]
        } as $items
      
        foreach ($items.items) {
          each as $item {
            function.run "Webflow/Business Listing -> Webflow Payload" {
              input = {properties: $item}
            } as $x1
          
            debug.log {
              value = $x1
            }
          
            !api.request {
              url = "https://api.webflow.com/v2/collections/684c0a9306c23f7bb7c088cf/items"
              method = "POST"
              params = $x1|!set:"items":$items_to_create
              headers = []
                |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
                |push:"Content-Type: application/json"
              timeout = 20
            } as $api_item
          
            array.push $items_to_create {
              value = $x1
            }
          
            !conditional {
              if ($api_item.response.status == 202) {
                db.patch business_listing_raw_data {
                  field_name = "id"
                  field_value = $item.id
                  data = {}
                    |set:"wf_item_id":$api_item.response.result.id
                    |set:"wf_fail":false
                } as $business_listing1
              
                array.push $patched_items {
                  value = $business_listing1
                }
              }
            
              else {
                db.patch business_listing_raw_data {
                  field_name = "id"
                  field_value = $item.id
                  data = {}|set:"wf_fail":true
                } as $business_listing2
              }
            }
          }
        }
      
        !conditional {
          if ($items.nextPage != true) {
            var.update $continue_loop {
              value = false
            }
          }
        
          else {
            var.update $page {
              value = $items.nextPage
            }
          }
        }
      
        api.request {
          url = "https://api.webflow.com/v2/collections/683a4969614808c01cd0d41f/items"
          method = "PATCH"
          params = {}|set:"items":$items_to_create
          headers = []
            |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
            |push:"Content-Type: application/json"
          timeout = 60
        } as $api1
      
        conditional {
          if ($api1.response.status == 202) {
            foreach ($api1.response.result.items) {
              each as $wf_item {
                !db.patch business_listing_raw_data {
                  field_name = "id"
                  field_value = $wf_item.fieldData["old-id"]
                  data = {}|set:"wf_item_id":$wf_item.id
                } as $business_listing1
              
                !db.patch business_listing {
                  field_name = "id"
                  field_value = $wf_item.fieldData["old-id"]
                  data = {}|set:"wf_item_id":$wf_item.id
                  output = ["id", "slug", "wf_item_id"]
                } as $business_listing_cleanup1
              
                db.edit business_listing {
                  field_name = "id"
                  field_value = $wf_item.fieldData["old-id"]
                  data = {wf_synced: true}
                } as $business_listing1
              
                array.push $patched_items {
                  value = $business_listing1
                }
              }
            }
          }
        
          else {
            !break
          }
        }
      }
    }
  
    !db.query business_listing_raw_data {
      where = $db.business_listing_raw_data.wf_item_id == ""
      return = {
        type  : "list"
        paging: {
          page    : $input.paging.page_nr
          per_page: $input.paging.items
        }
      }
    
      output = [
        "itemsReceived"
        "curPage"
        "nextPage"
        "prevPage"
        "offset"
        "itemsTotal"
        "pageTotal"
        "items.id"
        "items.title"
        "items.slug"
        "items.summary"
        "items.body_content"
        "items.push_to_wf_cms"
        "items.wf_fail"
        "items.category_id"
        "items.tag_id"
        "items.amenities"
        "items.working_hours"
        "items.website"
        "items.email"
        "items.main_image"
        "items.business_address"
        "items.latitude"
        "items.longitude"
        "items.facebook_url"
        "items.youtube_url"
        "items.twitter_url"
        "items.instagram_url"
        "items.pinterest_url"
        "items.tripadvisor_id"
        "items.partner_regions"
        "items.contact_phone"
        "items.meta_title"
        "items.meta_description"
        "items.s3_meta_image"
        "items.address.name"
        "items.address.street"
        "items.address.street2"
        "items.address.city"
        "items.address.region"
        "items.address.postalCode"
        "items.address.country"
        "items.address.countryName"
        "items.hero_image.access"
        "items.hero_image.path"
        "items.hero_image.name"
        "items.hero_image.type"
        "items.hero_image.size"
        "items.hero_image.mime"
        "items.hero_image.meta"
        "items.hero_image.url"
        "items.photos.index"
        "items.photos.category"
        "items.photos.url"
        "items.photos.alt"
        "items.photos.title"
        "items.more_images.access"
        "items.more_images.path"
        "items.more_images.name"
        "items.more_images.type"
        "items.more_images.size"
        "items.more_images.mime"
        "items.more_images.meta"
        "items.more_images.url"
        "items.meta_image.access"
        "items.meta_image.path"
        "items.meta_image.name"
        "items.meta_image.type"
        "items.meta_image.size"
        "items.meta_image.mime"
        "items.meta_image.meta"
        "items.meta_image.url"
      ]
    
      addon = [
        {
          name : "tag_item"
          input: {tag_id: $output.$this}
          addon: [
            {
              name  : "category"
              output: ["wf_id"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as   : "items.tag_id"
        }
        {
          name  : "places_cities_and_towns"
          output: ["region_id"]
          input : {places_cities_and_towns_id: $output.$this}
          addon : [
            {
              name : "places_regions"
              input: {places_regions_id: $output.region_id}
              as   : "_places_regions"
            }
            {
              name  : "places_regions"
              output: ["Item_ID"]
              input : {places_regions_id: $output.region_id}
              as    : "_places_regions"
            }
          ]
          as    : "items.partner_regions"
        }
        {
          name  : "amenity_1"
          output: ["wf_id"]
          input : {amenity_id: $output.$this}
          as    : "items.amenities"
        }
        {
          name : "s3_images"
          input: {s3_images_id: $output.s3_meta_image}
          as   : "items._s3_images"
        }
      ]
    } as $items
  
    !api.request {
      url = "https://api.webflow.com/v2/collections/684c0a9306c23f7bb7c088cf/items"
      method = "GET"
      headers = []
        |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
        |push:"Content-Type: application/json"
    } as $api_get
  }

  response = {
    a      : $api1.response
    result1: $items_to_create
    !busin : $business_listing1
    !patche: $patched_items
    items  : $items
  }

  tags = ["import"]
}