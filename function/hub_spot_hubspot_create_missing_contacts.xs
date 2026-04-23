// Create missing contacts from the User table
function "HubSpot/Hubspot -> Create Missing Contacts" {
  input {
  }

  stack {
    db.query user {
      join = {
        detail: {
          table: "user_detail"
          type : "left"
          where: $db.detail.user_id == $db.user.id
        }
      }
    
      where = $db.detail.user_id == null
      return = {type: "list"}
    } as $user1
  
    foreach ($user1) {
      each as $item {
        !db.get user_detail {
          field_name = "id"
          field_value = $item.id
        } as $user_detail1
      
        function.run "HubSpot/Hubspot -> Get Contact by Email" {
          input = {properties: [], email: $item.email, id: ""}
        } as $hubspot_user
      
        conditional {
          if ($hubspot_user.response.status != 200) {
            action.call "" {
              input = {
                first_name           : $item.first_name
                last_name            : $item.last_name
                email                : $item.email
                company              : ""
                lead_status          : ""
                contact_owner        : ""
                phone_number         : ""
                additional_properties: {"xano_id": $var.item.id}
              }
            
              registry = {hubspot_api_key: $env.hubspot_api}
            } as $action
          
            db.add user_detail {
              data = {
                created_at         : "now"
                address            : ""
                session_id         : 0
                hubspot_record_id  : $action.id
                user_id            : $item.id
                interests          : []
                email_preferences  : []
                onboarding_complete: false
                activities         : []
                companies          : []
                phone              : ""
                profile_image      : null
              }
            } as $user_details
          }
        
          elseif ($hubspot_user.response.status == 200) {
            db.add user_detail {
              data = {
                created_at         : "now"
                address            : ""
                session_id         : 0
                hubspot_record_id  : $hubspot_user.response.result.id
                user_id            : $item.id
                interests          : []
                email_preferences  : []
                onboarding_complete: false
                activities         : []
                companies          : []
                phone              : ""
                profile_image      : null
              }
            } as $user_details
          }
        }
      }
    }
  }

  response = $user1
  tags = ["import"]
}