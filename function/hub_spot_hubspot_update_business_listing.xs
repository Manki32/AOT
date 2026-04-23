// Function Documentation: HubSpot → Create Object
// 
// Overview
// This function creates a new business listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Update Business Listing" {
  input {
    json properties?
  }

  stack {
    // Set properties object
    group {
      stack {
        function.run "HubSpot/Business Listing -> Hubspot Payload" {
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
            object_type: "2-39805223"
            object_id  : $input.properties.hs_id
          }
        } as $func2
      }
    }
  }

  response = {
    !result1: $hubspot_api.response.result
    busine  : $func2
  }
}