// Login and retrieve an authentication token
query "auth/login" verb=POST {
  api_group = "Authentication - New"

  input {
    email email?
    text password?
    text turnstile? filters=trim
  }

  stack {
    db.get user {
      field_name = "email"
      field_value = $input.email|to_lower
      output = ["id", "password", "email_confirmed"]
    } as $user
  
    var $migrated_user {
      value = false
    }
  
    var $authToken {
      value = ""
    }
  
    precondition ($user != null) {
      error_type = "accessdenied"
      error = "Invalid Credentials."
    }
  
    conditional {
      if ($user.password != null) {
        security.check_password {
          text_password = $input.password
          hash_password = $user.password
        } as $pass_result
      
        precondition ($pass_result) {
          error_type = "accessdenied"
          error = "Invalid Credentials."
        }
      
        security.create_auth_token {
          table = "user"
          extras = {}
          expiration = 86400
          id = $user.id
        } as $authToken
      }
    
      else {
        var.update $migrated_user {
          value = true
        }
      }
    }
  }

  response = {
    authToken      : $authToken
    email_confirmed: $user.email_confirmed
    migrated       : $migrated_user
  }

  middleware = {pre: [{name: "validate_turnstile"}]}
}