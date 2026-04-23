function "HubSpot/upsert_hs_contact_after_order" {
  input {
    email email filters=trim|lower
    text first_name filters=trim
    text last_name filters=trim
    bool hs_marketable_status?
  }

  stack {
    function.run "HubSpot/Hubspot -> Get Contact by Email" {
      input = {properties: [], email: $input.email, id: ""}
    } as $hubspot_user
  
    conditional {
      if ($hubspot_user.response.status != 200) {
        action.call "" {
          input = {
            first_name           : $input.first_name
            last_name            : $input.last_name
            email                : $input.email
            company              : ""
            lead_status          : ""
            contact_owner        : ""
            phone_number         : ""
            additional_properties: ```
              {
                  "hs_marketable_status": $input.hs_marketable_status,
                  "placed_order": "true"
              }
              ```
          }
        
          registry = {hubspot_api_key: $env.hubspot_api}
        } as $action
      }
    
      else {
        action.call "" {
          input = {
            first_name           : ""
            last_name            : ""
            email                : ""
            company              : ""
            lead_status          : ""
            contact_owner        : ""
            phone_number         : ""
            contact_id           : $hubspot_user.response.result.id
            additional_properties: ```
              {
                  "hs_marketable_status": $input.hs_marketable_status,
                  "placed_order": "true"
              }
              ```
          }
        
          registry = {hubspot_api_key: $env.hubspot_api}
        } as $action
      }
    }
  
    util.get_vars as $__all_vars
  }

  response = {
    hubspot_user: $__all_vars|get:"hubspot_user":null
    action      : $__all_vars|get:"action":null
  }
}