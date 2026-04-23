function "Webflow/Webflow -> Update Event Listing" {
  input {
    json properties?
  }

  stack {
    function.run "Webflow/Event Listing -> Webflow Payload" {
      input = {properties: $input.properties}
    } as $x1
  
    group {
      stack {
        api.request {
          url = "https://api.webflow.com/v2/collections/683a4969614808c01cd0d408/items/" ~ $input.properties.wf_id ~ "/live?skipInvalidFiles=true"
          method = "PATCH"
          params = $x1
          headers = []
            |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
            |push:"Content-Type: application/json"
          timeout = 20
        } as $api_1
      }
    }
  
    // Timeout if
    conditional {
      if ($api_1.response.status === 429) {
        var $retry_after_n {
          value = $api_1.response.headers.4
            |split:": "
            |last
            |to_int
        }
      
        util.sleep {
          value = $retry_after_n
        }
      
        api.request {
          url = "https://api.webflow.com/v2/collections/683a4969614808c01cd0d408/items/" ~ $input.properties.wf_id ~ "/live?skipInvalidFiles=true"
          method = "PATCH"
          params = $x1
          headers = []
            |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
            |push:"Content-Type: application/json"
          timeout = 20
        } as $api_1
      }
    }
  
    precondition ($api_1.response.status === 200) {
      error = "Webflow sync failed"
      payload = $api_1.response.result
    }
  }

  response = {result: $api_1}
}