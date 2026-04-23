// Set status to approved after receiving webhook from hubspot
query "webhook/reject_event" verb=POST {
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
  
    db.edit event {
      field_name = "id"
      field_value = $payload.xano_id
      data = {status: "Rejected"}
      addon = [
        {
          name : "event_categories"
          input: {event_categories_id: $output.$this}
          addon: [
            {
              name  : "category"
              output: ["slug", "wf_id"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as   : "event_categories"
        }
        {
          name  : "related_partners"
          output: ["slug", "wf_item_id"]
          input : {business_listing_cleanup_id: $output.$this}
          as    : "related_partners"
        }
        {
          name  : "places_cities_and_towns"
          output: ["slug", "wf_id", "region_id"]
          input : {places_cities_and_towns_id: $output.$this}
          addon : [
            {
              name  : "places_regions"
              output: ["Item_ID"]
              input : {places_regions_id: $output.region_id}
              as    : "_places_regions"
            }
          ]
          as    : "partner_regions"
        }
      ]
    } as $event1
  }

  response = {result1: $payload, event: $event1}
}