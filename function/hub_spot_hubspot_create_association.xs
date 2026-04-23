// Create an association between two Hubspot records
function "HubSpot/Hubspot -> Create Association" {
  input {
    text from_object_type filters=trim
    text from_object_id filters=trim
    text to_object_type filters=trim
    text to_object_id filters=trim
  }

  stack {
    api.request {
      url = "https://api.hubapi.com/crm/v4/objects/" ~ $input.from_object_type ~ "/" ~ $input.from_object_id ~ "/associations/default/" ~ $input.to_object_type ~ "/" ~ $input.to_object_id
      method = "PUT"
      params = {}
        |set:"objectWriteTraceId":(""|create_uid)
      headers = []
        |push:("authorization: Bearer %s"|sprintf:$env.hubspot_api)
        |push:"Content-Type: application/json"
    } as $hs_api
  
    precondition ($hs_api.response.status == 200 || $hs_api.response.status == 201) {
      error = "Uh oh! Hubspot returned with an error: %s"
        |sprintf:$hs_api.response.result.message
    }
  }

  response = $hs_api.response.result
  history = 100
}