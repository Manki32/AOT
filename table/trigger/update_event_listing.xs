table_trigger update_event_listing {
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
        {
          name : "user"
          input: {user_id: $output.owner_id}
          as   : "user"
        }
        {
          name  : "user"
          output: ["email"]
          input : {user_id: $output.$this}
          as    : "user_id"
        }
      ]
    } as $listing
  
    function.run "HubSpot/Hubspot -> Update Event Listing" {
      input = {properties: $listing}
    } as $func2
  
    function.run sendgrid_dynamic_send {
      input = {
        template_id: "d-44275828239a464885facc7cbc6ac252"
        data       : {}|set:"listing_type":"event"|set:"first_name":$listing.user.first_name|set:"listing_title":$listing.name
        to_email   : $listing.user_id
      }
    } as $sendgridEmail
  }

  where = $db.NEW.status == "Requesting approval"
  actions = {update: true}
  datasources = ["live"]
}