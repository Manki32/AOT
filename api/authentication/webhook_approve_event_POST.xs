// Set status to approved after receiving webhook from hubspot
query "webhook/approve_event" verb=POST {
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
  
    // Get Event Categories From Payload
    group {
      stack {
        api.lambda {
          code = """
            const tags = $var.payload.highlight_tags || ""
            
            return tags.split(";").map(item => item.trim());
            """
          timeout = 10
        } as $tags_array
      
        db.query tag {
          where = $db.tag.name in $tags_array
          return = {type: "list"}
          output = ["id"]
        } as $tag_ids
      
        api.lambda {
          code = "return $var.tag_ids.map(item => item.id)"
          timeout = 10
        } as $tags
      }
    }
  
    db.edit event {
      field_name = "id"
      field_value = $payload.xano_id
      data = {
        featured      : $payload.featured
        status        : "Approved"
        highlight_tags: $tags
      }
    
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
        {
          name  : "category"
          output: ["wf_id"]
          input : {category_id: $output.$this}
          as    : "categories"
        }
        {
          name : "user"
          input: {user_id: $output.owner_id}
          as   : "user"
        }
        {
          name  : "tag_item"
          output: ["id", "wf_id", "category_id", "alt_tag"]
          input : {tag_id: $output.$this}
          addon : [
            {
              name  : "category"
              output: ["id", "wf_id"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as    : "highlight_tags"
        }
      ]
    } as $event1
  
    conditional {
      if ($event1.wf_id != "") {
        function.run "Webflow/Webflow -> Update Event Listing" {
          input = {properties: $event1}
        } as $func2
      }
    
      else {
        function.run "Webflow/Webflow -> Create Event Listing" {
          input = {properties: $event1}
        } as $func1
      }
    }
  }

  response = {result1: $payload, eve: $tags}
}