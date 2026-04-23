function "Packem/packem_get_inventory_all" {
  input {
  }

  stack {
    function.run "Packem/packem_auth" {
      input = {force_refresh: false}
    } as $func1
  
    api.request {
      url = "https://external.packem-wms.com/api/Inventory/all"
      method = "GET"
      params = ""
      headers = []
        |push:"content-type: application/*+json"
        |push:"authorization:Bearer " ~ $var.func1
    } as $api1
  
    precondition ($api1.response.status == 200) {
      error_type = "accessdenied"
      error = "Access Denied"
      payload = $api1.response
    }
  }

  response = $api1.response.result
}