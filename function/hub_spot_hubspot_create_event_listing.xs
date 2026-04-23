// Function Documentation: HubSpot → Create Object
// 
// Overview
// This function creates a new business listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Create Event Listing" {
  input {
    json properties?
  }

  stack {
    // Set properties object
    group {
      stack {
        function.run "HubSpot/Event Listing -> Hubspot Payload" {
          input = {properties: $input.properties}
        } as $properties_object
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
          field_value = $input.properties.id
          data = {hs_id: $hs_result.id}
          addon = [
            {
              name  : "user_details_of_user"
              output: ["hubspot_record_id"]
              input : {user_id: $output.$this}
              as    : "user_id"
            }
          ]
        } as $event2
      
        foreach ($event2.user_id) {
          each as $item {
            function.run "HubSpot/Hubspot -> Create Association" {
              input = {
                from_object_type: "2-39972221"
                from_object_id  : $hs_result.id
                to_object_type  : "contacts"
                to_object_id    : $item.hubspot_record_id
              }
            } as $func1
          }
        }
      
        !util.sleep {
          value = 0.25
        }
      }
    }
  }

  response = {
    !result1: $hubspot_api.response.result
    busine  : $hs_result
  }

  history = 100
}