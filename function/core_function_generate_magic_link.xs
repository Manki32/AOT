// This function generates a magic token with a 60 minute expiration date.
function "core function/generate_magic_link" {
  input {
    email email?
    text url? filters=trim
  }

  stack {
    precondition ($input.email != null) {
      error = "email is required but was not suppiled. "
    }
  
    db.get user {
      field_name = "email"
      field_value = $input.email
    } as $user
  
    precondition ($user != null) {
      error_type = "notfound"
      error = "No user found for that email."
    }
  
    security.create_password {
      character_count = 12
      require_lowercase = true
      require_uppercase = true
      require_digit = true
      require_symbol = false
      symbol_whitelist = ""
    } as $token
  
    var $magic_link {
      value = {}
        |set:"token":$token
        |set:"expiration":(now
          |add_secs_to_timestamp:($env.magic_link_expiry_time|to_int)
        )
        |set:"used":false
    }
  
    var $jwt_payload {
      value = {}
        |set:"user_id":($user|get:"id":0)
        |set:"magic_token":($magic_link|get:"token":null)
    }
  
    db.edit user {
      field_name = "id"
      field_value = $user.id
      data = {magic_link: $magic_link}
    } as $user
  
    security.jwe_encode_legacy {
      payload = $jwt_payload
      audience = "Xano"
      key = $env.magic_jwt_secret
      key_algorithm = "A256KW"
      content_algorithm = "A256CBC-HS512"
    } as $jwt
  
    var $magic_link {
      value = $input.url
        |url_addarg:"magic_token":$jwt:false
    }
  }

  response = $magic_link
}