// On insert: sync the new event listing to HubSpot. Alerts admins only
// when the listing is already in "Requesting approval" state (drafts stay silent).
table_trigger insert_event_listing {
  table = "event"

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
        endpoint   : "Trigger: insert_event_listing"
        method     : "TRIGGER"
        status     : 200
        input_data : $input.new
        output_data: {message: "Trigger started"}
      }
    }
  
    db.get event {
      field_name = "id"
      field_value = $input.new.id
      addon = [
        {
          name : "event_categories"
          input: {event_categories_id: $output.$this}
          addon: [
            {
              name  : "category"
              output: ["name"]
              input : {category_id: $output.category_id}
              as    : "_category"
            }
          ]
          as   : "event_categories"
        }
        {
          name  : "related_partners"
          output: ["id", "title", "hs_id", "wf_item_id"]
          input : {business_listing_cleanup_id: $output.$this}
          as    : "related_partners"
        }
        {
          name  : "places_cities_and_towns"
          output: ["title", "slug", "wf_id", "region_id"]
          input : {places_cities_and_towns_id: $output.$this}
          addon : [
            {
              name  : "places_regions"
              output: ["Name", "Slug"]
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
        {
          name  : "category"
          output: ["name"]
          input : {category_id: $output.$this}
          as    : "categories"
        }
      ]
    } as $listing
  
    // Only alert on real sync failures. Drafts (not yet "Requesting approval")
    // commonly fail HubSpot sync due to missing data — that is expected.
    try_catch {
      try {
        function.run "HubSpot/Hubspot -> Create Event Listing" {
          input = {properties: $listing}
        } as $func1
      }
    
      catch {
        conditional {
          if ($input.new.status == "Requesting approval") {
            function.run "alerts/send_integration_failure_alert" {
              input = {
                category       : "events"
                integration    : "HubSpot"
                event_type     : "Event Listing Sync Failed"
                what_went_wrong: "A new event listing was submitted for approval but failed to sync to HubSpot. The listing exists in Xano but is not yet in HubSpot."
                source         : "Xano"
                destination    : "HubSpot"
                listing_name   : $listing.name
                listing_id     : $listing.id
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