query "webhook/event_listing_assign_user" verb=POST {
  api_group = "Authentication"

  input {
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $payload
  
    var $base_url {
      value = "https://extranet.visitarizona.com"
    }
  
    db.get user {
      field_name = "email"
      field_value = $payload.email
    } as $user
  
    db.get event {
      field_name = "id"
      field_value = $payload.xano_event_listing_id
    } as $event
  
    conditional {
      if ($user != false) {
        db.edit event {
          field_name = "id"
          field_value = $payload.xano_event_listing_id
          data = {user_id: $event.user_id|push:$user.id|unique:""}
          output = ["name", "user_id"]
        } as $event
      
        function.run sendgrid_dynamic_send {
          input = {
            template_id: "d-7d381349448a475583f74711dc807b06"
            data       : {}|set:"first_name":$user.first_name|set:"listing_name":$event.name|set:"login_link":`$var.base_url|concat:("/events-listings/event-listing-item?eventid="|concat:$var.event.id:):`
            to_email   : []|push:({}|set:"email":$user.email)
          }
        } as $func1
      }
    
      else {
        // Missing backend logic for handling new users - need to add front-end functionality to tackle use case: 
        group {
          stack {
            db.add user {
              data = {
                created_at     : "now"
                first_name     : $payload.first_name
                last_name      : $payload.last_name
                email          : $payload.email
                password       : null
                email_confirmed: false
                role           : "User"
                deleted        : false
              }
            } as $new_user
          
            db.edit event {
              field_name = "id"
              field_value = $payload.xano_event_listing_id
              data = {user_id: $event.user_id|push:$new_user.id}
            } as $event1
          
            function.run sendgrid_dynamic_send {
              input = {
                template_id: "d-f05e4df6ea3546a586a3dec4c59c95c3"
                data       : {}|set:"listing_name":$event1.name|set:"user_email":$new_user.email|set:"signup_link":($base_url|concat:("/auth/forgot-password?user="|concat:($new_user.email|concat:"&activate=true":""):""):"")|set:"first_name":$user.first_name
                to_email   : []|push:({}|set:"email":$new_user.email)
              }
            } as $func2
          }
        }
      }
    }
  }

  response = $payload
}