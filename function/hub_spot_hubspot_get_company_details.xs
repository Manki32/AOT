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
      
        // Log the outbound request
        function.run "core/log_request" {
          input = {
            endpoint   : ("https://api.hubapi.com/crm/v3/objects/company/" ~ $input.id)
            method     : "GET"
            status     : $hubspot_api.response.status|to_int
            input_data : {id: $input.id, properties: $input.properties}
            output_data: $hubspot_api.response.result
          }
        }
      }
    }
  }

  response = $hubspot_api.response.result
}