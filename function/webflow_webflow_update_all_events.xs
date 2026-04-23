function "Webflow/Webflow -> Update All Events" {
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
      
        !db.query business_listing {
          where = $db.business_listing.wf_item_id == ""
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
      
        db.query event {
          return = {
            type  : "list"
            paging: {page: $page, per_page: $input.paging.items}
          }
        
          addon = [
            {
              name : "event_categories"
              input: {event_categories_id: $output.$this}
              addon: [
                {
                  name  : "category"
                  output: ["wf_id"]
                  input : {category_id: $output.category_id}
                  as    : "_category"
                }
              ]
              as   : "items.event_categories"
            }
            {
              name  : "places_cities_and_towns"
              output: ["wf_id", "region_id"]
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
              name  : "related_partners"
              output: ["wf_item_id"]
              input : {business_listing_cleanup_id: $output.$this}
              as    : "items.related_partners"
            }
            {
              name : "category"
              input: {category_id: $output.$this}
              as   : "items.categories"
            }
          ]
        } as $items
      
        foreach ($items.items) {
          each as $item {
            function.run "Webflow/Event Listing -> Webflow Payload" {
              input = {properties: $item}
            } as $x1
          
            !debug.log {
              value = $x1
            }
          
            var $payload {
              value = {}
                |set:"id":$item.wf_id
                |set:"fieldData":$x1.fieldData
            }
          
            array.push $items_to_create {
              value = $payload
            }
          }
        }
      
        api.request {
          url = 'https://api.webflow.com/v2/collections/683a4969614808c01cd0d408/items/live?skipInvalidFiles=true"'
          method = "PATCH"
          params = {}|set:"items":$items_to_create
          headers = []
            |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
            |push:"Content-Type: application/json"
          timeout = 60
        } as $api1
      
        !conditional {
          if ($api1.response.status == 202) {
            foreach ($api1.response.result.items) {
              each as $wf_item {
                !db.patch business_listing_raw_data {
                  field_name = "id"
                  field_value = $wf_item.fieldData["old-id"]
                  data = {}|set:"wf_item_id":$wf_item.id
                } as $business_listing1
              
                db.patch event {
                  field_name = "id"
                  field_value = $wf_item.fieldData["old-id"]
                  data = {}|set:"wf_id":$wf_item.id
                } as $event1
              
                array.push $patched_items {
                  value = $event1
                }
              }
            }
          }
        
          else {
            break
          }
        }
      
        !debug.stop {
          value = ""
        }
      }
    }
  }

  response = {
    a       : $api1.response
    !result1: $items_to_create
    !busin  : $business_listing1
    !patche : $patched_items
    items   : $items
  }
}