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
  
    function.run "HubSpot/Hubspot -> Create Business Listing" {
      input = {properties: $business_listing}
    } as $func1
  }

  actions = {insert: true}
  datasources = ["live"]
}