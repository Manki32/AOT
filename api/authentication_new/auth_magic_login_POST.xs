// Exchanges magic token for auth token
query "auth/magic-login" verb=POST {
  api_group = "Authentication - New"

  input {
    text magic_token? filters=trim
  }

  stack {
    precondition ($input.magic_token != null) {
      error = "magic_token is required but was not provided."
    }
  
    security.jwe_decode_legacy {
      token = $input.magic_token
      key = $env.magic_jwt_secret
      audience = "Xano"
      key_algorithm = "A256KW"
      content_algorithm = "A256CBC-HS512"
    } as $decoded_magic_token
  
    precondition (($decoded_magic_token|get:"user_id":null) != null && ($decoded_magic_token|get:"magic_token":null) != null) {
      error = "Corrupt magic_token. Please request another magic link."
    }
  
    db.get user {
      field_name = "id"
      field_value = $decoded_magic_token|get:"user_id":null
    } as $user
  
    precondition ($user.magic_link.token == $decoded_magic_token.magic_token) {
      error = "Incorrect magic_token. Please request another one."
    }
  
    precondition ($user.magic_link.expiration > now) {
      error = "Magic token has expired. Please request another one."
    }
  
    precondition ($user.magic_link.used == false) {
      error = "This magic link has already been used. Please request another one."
    }
  
    security.create_auth_token {
      table = "user"
      extras = ""
      expiration = 86400
      id = $user.id
    } as $auth_token
  
    var.update $user.magic_link.used {
      value = true
    }
  
    db.edit user {
      field_name = "id"
      field_value = $user.id
      data = {magic_link: $user.magic_link}
    } as $user
  }

  response = $auth_token
}