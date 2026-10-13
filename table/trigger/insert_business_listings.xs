// On insert: sync the new business listing to HubSpot. Alerts admins only
// when the listing is already in "Requesting Approval" state (drafts stay silent).
table_trigger insert_business_listings {
  table = "business_listing"

  input {
    json new
    json old
    enum action {
      values = ["insert", "update", "delete", "truncate"]
    }
  
    text datasource
  }

  stack {
    // Log the trigger activation
    function.run "core/log_request" {
      input = {
        endpoint   : "Trigger: insert_business_listings"
        method     : "TRIGGER"
        status     : 200
        input_data : $input.new
        output_data: {message: "Trigger started"}
      }
    }
  
    db.get business_listing {
      field_name = "id"
      field_value = $input.new.id
      addon = [
        {
          name  : "tag_item"
          output: ["name", "category_id"]
          input : {tag_id: $output.$this}
          addon : [
            {
              name  : "category"
              output: ["name"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as    : "tag_id"
        }
        {
          name  : "amenity_1"
          output: ["name"]
          input : {amenity_id: $output.$this}
          as    : "amenities"
        }
        {
          name  : "places_cities_and_towns"
          output: ["title", "region_id"]
          input : {places_cities_and_towns_id: $output.$this}
          addon : [
            {
              name  : "places_regions"
              output: ["Name"]
              input : {places_regions_id: $output.region_id}
              as    : "_places_regions"
            }
          ]
          as    : "partner_regions"
        }
        {
          name  : "user_details_of_user"
          output: ["hubspot_record_id"]
          input : {user_id: $output.owner_id}
          as    : "_user_details"
        }
      ]
    } as $business_listing
  
    // Only alert on real sync failures. Drafts (not yet "Requesting Approval")
    // commonly fail HubSpot sync due to missing data — that is expected.
    try_catch {
      try {
        function.run "HubSpot/Hubspot -> Create Business Listing" {
          input = {properties: $business_listing}
        } as $func1
      }
    
      catch {
        conditional {
          if ($input.new.status == "Requesting Approval") {
            function.run "alerts/send_integration_failure_alert" {
              input = {
                category       : "business"
                integration    : "HubSpot"
                event_type     : "Business Listing Sync Failed"
                what_went_wrong: "A new business listing was submitted for approval but failed to sync to HubSpot. The listing exists in Xano but is not yet in HubSpot."
                source         : "Xano"
                destination    : "HubSpot"
                listing_name   : $business_listing.title
                listing_id     : $business_listing.id
                raw_error      : "See logs for the HubSpot response. The sync function raised and this catch handler fired."
              }
            }
          }
        }
      }
    }
  }

  actions = {insert: true}
  datasources = ["live"]
}