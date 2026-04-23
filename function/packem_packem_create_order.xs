function "Packem/packem_create_order" {
  input {
    text referenceNo filters=trim
  
    // Full name
    text shipToName filters=trim
  
    text shipToAddress1 filters=trim
    text shipToAddress2? filters=trim
    text shipToCity filters=trim
    text shipToPostalCode? filters=trim
    text shipToCountry filters=trim
    text shipToState filters=trim
    text shipToPhone filters=trim
    text shipToEmail filters=trim
    text billingCompany? filters=trim
    bool isB2B?
    json[] items
  }

  stack {
    function.run "Packem/packem_auth" {
      input = {force_refresh: false}
    } as $func1
  
    api.request {
      url = "https://external.packem-wms.com/api/Order/create"
      method = "POST"
      params = {}
        |set:"referenceNo":$input.referenceNo
        |set:"shipToName":$input.shipToName
        |set:"shipToAddress1":$input.shipToAddress1
        |set:"shipToCity":$input.shipToCity
        |set:"shipToPostalCode":$input.shipToPostalCode
        |set:"shipToCountry":$input.shipToCountry
        |set:"shipToState":$input.shipToState
        |set:"shipToAddress2":$input.shipToAddress2
        |set:"shipToPhone":$input.shipToPhone
        |set:"shipToEmail":$input.shipToEmail
        |set:"lineItems":$input.items
        |set:"billingCompany":$input.billingCompany
        |set:"isB2B":$input.isB2B
        |set:"shipToCompany":$input.billingCompany
      headers = []
        |push:"accept: application/json"
        |push:"content-type: application/*+json"
        |push:"authorization: Bearer " ~ $var.func1
    } as $api1
  }

  response = $api1.response
}