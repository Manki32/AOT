// Function Documentation: HubSpot → Create Object
// 
// Overview
// This function creates a new business listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Create All Event Listings" {
  input {
    json properties?
  }

  stack {
    db.query event {
      where = $db.event.hs_id == "" && $db.event.owner_id != 0
      return = {type: "list", paging: {page: 1, per_page: 200}}
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
          as   : "items.event_categories"
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
          as    : "items.partner_regions"
        }
        {
          name  : "user_details_of_user"
          output: ["hubspot_record_id"]
          input : {user_id: $output.owner_id}
          as    : "items._user_details"
        }
      ]
    } as $event1
  
    var $items_to_create {
      value = []
    }
  
    foreach ($event1.items) {
      each as $item {
        // Set properties object
        group {
          stack {
            function.run "HubSpot/Event Listing -> Hubspot Payload" {
              input = {properties: $item}
            } as $properties_object
          
            array.push $items_to_create {
              value = $properties_object
            }
          }
        }
      
        // Hubspot API Requests
        group {
          stack {
            function.run "HubSpot/Hubspot -> Create Object" {
              input = {
                properties            : $properties_object
                hubspot_object_type_id: "2-39972221"
              }
            } as $hs_result
          
            db.edit event {
              field_name = "id"
              field_value = $item.id
              data = {hs_id: $hs_result.id}
            } as $event2
          
            util.sleep {
              value = 0.25
            }
          
            function.run "HubSpot/Hubspot -> Create Association" {
              input = {
                from_object_type: "2-39972221"
                from_object_id  : $hs_result.id
                to_object_type  : "contacts"
                to_object_id    : $item._user_details.hubspot_record_id
              }
            } as $func1
          }
        }
      
        !conditional {
          if ($hs_api.response.status == 201) {
          }
        }
      }
    }
  }

  response = {
    !result1: $hubspot_api.response.result
    events  : $event1
    te      : $items_to_create
  }
}