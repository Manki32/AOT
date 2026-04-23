// Triggers when business listing status is set to Requesting Approval
table_trigger update_business_listing {
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
    } as $business_listing
  
    function.run "HubSpot/Hubspot -> Update Business Listing" {
      input = {properties: $business_listing}
    } as $hubspotSync
  
    function.run sendgrid_dynamic_send {
      input = {
        template_id: "d-44275828239a464885facc7cbc6ac252"
        data       : {}|set:"listing_type":"business"|set:"first_name":$business_listing.user.first_name|set:"listing_title":$business_listing.title
        to_email   : $business_listing.user_id
      }
    } as $sendgridEmail
  }

  where = $db.NEW.status == "Requesting Approval"
  actions = {update: true}
}