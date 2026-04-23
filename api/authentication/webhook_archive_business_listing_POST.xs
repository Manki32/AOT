// Set status to approved after receiving webhook from hubspot
query "webhook/archive_business_listing" verb=POST {
  api_group = "Authentication"

  input {
  }

  stack {
    precondition ($env.$http_headers.Authorization == $env.xano_api_hubspot) {
      error_type = "unauthorized"
      error = "Unauthorized"
      payload = "Unauthorized - please provide a valid authentication token"
    }
  
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $payload
  
    db.edit business_listing {
      field_name = "id"
      field_value = $payload.xano_id
      data = {status: "Archived"}
      addon = [
        {
          name  : "tag_item"
          output: ["id", "name", "slug", "old_crm_id", "wf_id", "category_id"]
          input : {tag_id: $output.$this}
          addon : [
            {
              name  : "category"
              output: ["wf_id"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as    : "tag_id"
        }
        {
          name : "amenity_1"
          input: {amenity_id: $output.$this}
          as   : "amenities"
        }
        {
          name  : "places_cities_and_towns"
          output: ["wf_id", "region_id"]
          input : {places_cities_and_towns_id: $output.$this}
          addon : [
            {
              name  : "places_regions"
              output: ["id", "Item_ID"]
              input : {places_regions_id: $output.region_id}
              as    : "_places_regions"
            }
          ]
          as    : "partner_regions"
        }
        {
          name : "user"
          input: {user_id: $output.owner_id}
          as   : "user"
        }
      ]
    } as $business_listing
  
    conditional {
      if ($business_listing.wf_item_id != "") {
        function.run "Webflow/Webflow -> Delete Business Listing" {
          input = {properties: $business_listing}
        } as $func1
      }
    }
  }

  response = {result1: $payload, !tag: $tags}
}