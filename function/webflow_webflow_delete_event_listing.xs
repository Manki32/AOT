function "Webflow/Webflow -> Delete Event Listing" {
  input {
    json properties?
  }

  stack {
    group {
      stack {
        api.request {
          url = `"https://api.webflow.com/v2/collections/683a4969614808c01cd0d408/items"`
          method = "DELETE"
          params = {}
            |set:"items":([]
              |push:({}|set:"id":$input.properties.wf_id)
            )
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
          url = `"https://api.webflow.com/v2/collections/683a4969614808c01cd0d408/items"`
          method = "DELETE"
          params = {}
            |set:"items":([]
              |push:({}|set:"id":$input.properties.wf_id)
            )
          headers = []
            |push:("Authorization: Bearer "|concat:$env.wf_api_token:"")
            |push:"Content-Type: application/json"
          timeout = 20
        } as $api_1
      }
    }
  
    precondition ($api_1.response.status === 204) {
      error = "Webflow sync failed"
      payload = $api_1.response
    }
  
    db.patch event {
      field_name = "id"
      field_value = $input.properties.id
      data = {}|set:"wf_id":""
    } as $event2
  }

  response = $api_1.response.result
}