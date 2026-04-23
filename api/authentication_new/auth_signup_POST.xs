// Signup and retrieve an authentication token
query "auth/signup" verb=POST {
  api_group = "Authentication - New"

  input {
    text first_name?
    email email?
    text password?
    text last_name? filters=trim
    text turnstile? filters=trim
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user == null) {
      error_type = "accessdenied"
      error = "This account is already in use."
    }
  
    db.add user {
      data = {
        created_at: "now"
        first_name: $input.first_name
        last_name : $input.last_name
        email     : $input.email|to_lower
        password  : $input.password
        role      : "User"
        deleted   : false
        magic_link: null
      }
    } as $user
  
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
            additional_properties: {"xano_id": $user.id}
          }
        
          registry = {hubspot_api_key: $env.hubspot_api}
        } as $action
      
        db.add user_detail {
          data = {
            created_at         : "now"
            address            : ""
            session_id         : 0
            hubspot_record_id  : $action.id
            user_id            : $user.id
            interests          : []
            email_preferences  : []
            onboarding_complete: false
            activities         : []
            profile_image      : null
          }
        } as $user_details
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
              "xano_id": $user.id
              }
              ```
          }
        
          registry = {hubspot_api_key: $env.hubspot_api}
        } as $action
      
        db.add user_detail {
          data = {
            created_at         : "now"
            hubspot_record_id  : $action.id
            user_id            : $user.id
            onboarding_complete: false
          }
        } as $user_details
      }
    }
  
    security.create_auth_token {
      table = "user"
      extras = {}
      expiration = 86400
      id = $user.id
    } as $authToken
  }

  response = {authToken: $authToken}
  middleware = {pre: [{name: "validate_turnstile"}]}
}