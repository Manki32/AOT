// Get Company Details
function "HubSpot/Hubspot -> Get Company Details" {
  input {
    text[] properties? filters=trim
    text id? filters=trim
  }

  stack {
    // Hubspot API Request
    group {
      stack {
        api.request {
          url = "https://api.hubapi.com/crm/v3/objects/company/"|concat:$input.id:""
          method = "GET"
          params = {}
            |set:"limit":"10"
            |set:"archived":"false"
            |set:"properties":($input.properties|join:",")
          headers = []
            |push:("Authorization: Bearer"|concat:$env.hubspot_api:" ")
        } as $hubspot_api
      }
    }
  }

  response = $hubspot_api.response.result
}