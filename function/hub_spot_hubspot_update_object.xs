// Function Documentation: HubSpot → Create Object
// 
// Overview
// This function creates a new business listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Update Object" {
  input {
    json properties?
  
    // Object type ID that needs to be updated
    text object_type? filters=trim
  
    // Record ID for hubspot item that needs to be updates
    text object_id? filters=trim
  }

  stack {
    // Hubspot API Request
    group {
      stack {
        api.request {
          url = "https://api.hubapi.com/crm/v3/objects/" ~ $input.object_type ~ "/" ~ $input.object_id
          method = "PATCH"
          params = {}
            |set:"objectWriteTraceId":(""|create_uid)
            |set:"properties":$input.properties
          headers = []
            |push:("authorization: Bearer %s"|sprintf:$env.hubspot_api)
            |push:"content-type: application/json"
        } as $hs_api
      }
    }
  
    precondition ($hs_api.response.status == 201 || $hs_api.response.status == 200) {
      error = "Uh oh! Hubspot returned with an error: %s"
        |sprintf:$hs_api.response.result.message
    }
  }

  response = $hs_api.response.result
}