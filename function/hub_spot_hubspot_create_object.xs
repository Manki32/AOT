// Function Documentation: HubSpot → Create Object
// 
// Overview
// This function creates a new business listing in HubSpot using specified input parameters. It involves setting environment variables, preparing the request, and handling the response.
function "HubSpot/Hubspot -> Create Object" {
  input {
    json properties?
    text hubspot_object_type_id? filters=trim
  }

  stack {
    // Hubspot API Request
    group {
      stack {
        api.request {
          url = "https://api.hubapi.com/crm/v3/objects/"
            |concat:$input.hubspot_object_type_id:"/"
          method = "POST"
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
      payload = $hs_api.response.result
    }
  }

  response = $hs_api.response.result
  history = 100
}