query order verb=POST {
  api_group = "Default"

  input {
    text first_name filters=trim
    text last_name filters=trim
    text address filters=trim
    text address2? filters=trim
    text city filters=trim
    text zip filters=trim
    text state filters=trim
    text phone filters=trim
    email email filters=trim|lower
    text company_name? filters=trim
    date? traveling_start_date?
    date? traveling_end_date?
    bool personalization?
    object[1:] items {
      schema {
        text sku? filters=trim
        text quantity? filters=trim
        text unitOfMeasure? filters=trim
        text eachesPercase? filters=trim
      }
    }
  
    int[] interests?
    text turnstile filters=trim
    text page_path filters=trim
    bool isB2B
    text country?=US filters=trim
  }

  stack {
    conditional {
      if ($input.page_path == "bulk-maps-guides") {
        precondition ($input.company_name != "") {
          error = "Company name can't be empty"
        }
      }
    }
  
    var $user_id {
      value = null
    }
  
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user1
  
    conditional {
      if ($user1 != false) {
        var.update $user_id {
          value = $user1.id
        }
      }
    }
  
    db.add order {
      data = {
        created_at          : "now"
        user_id             : $user_id
        first_name          : $input.first_name
        last_name           : $input.last_name
        address             : $input.address
        address2            : $input.address2
        city                : $input.city
        zip                 : $input.zip
        state               : $input.state
        phone               : $input.phone
        email               : $input.email
        company_name        : $input.company_name
        interests           : $input.interests
        traveling_start_date: $input.traveling_start_date
        traveling_end_date  : $input.traveling_end_date
        personalization     : $input.personalization
      }
    } as $order1
  
    function.run "Packem/packem_create_order" {
      input = {
        referenceNo     : $order1.id
        shipToName      : $input.first_name ~ " " ~ $input.last_name
        shipToAddress1  : $input.address
        shipToAddress2  : $input.address2
        shipToCity      : $input.city
        shipToPostalCode: $input.zip
        shipToCountry   : $input.country
        shipToState     : $input.state
        shipToPhone     : $input.phone
        shipToEmail     : $input.email
        billingCompany  : $input.company_name
        isB2B           : $input.isB2B
        items           : $input.items|json_encode
      }
    } as $func1
  
    precondition ($func1.status == 200) {
      error_type = "inputerror"
      error = "There was an error with your order. Please try again later."
      payload = $func1
    }
  
    db.edit order {
      field_name = "id"
      field_value = $order1.id
      data = {
        synced_to_epi_hab: true
        packem_id        : $func1.result|get:"orderNo":null
      }
    } as $order2
  }

  response = $order2
  middleware = {pre: [{name: "validate_turnstile"}]}
}