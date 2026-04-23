// Function Documentation: HubSpot → Update Object
// 
// Overview
// This function updates an event listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Update Event Listing" {
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
  
    // Hubspot API Request
    group {
      stack {
        function.run "HubSpot/Hubspot -> Update Object" {
          input = {
            properties : $properties_object
            object_type: "2-39972221"
            object_id  : $input.properties.hs_id
          }
        } as $hs_result
      }
    }
  }

  response = {
    !result1: $hubspot_api.response.result
    busine  : $hs_result
  }
}