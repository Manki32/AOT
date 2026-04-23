// Endpoint to reset the password of a user
query "auth/reset-password" verb=POST {
  api_group = "Authentication - New"
  auth = "user"

  input {
    text password? filters=trim|min:8
    text confirm_password? filters=trim
    text turnstile? filters=trim
  }

  stack {
    precondition ($input.password == $input.confirm_password) {
      error = "Passwords do not match."
    }
  
    function.run "core function/base_url" {
      input = {
        environment: $env.$http_headers|get:"X-Data-Source":"live"
      }
    } as $base_url
  
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {password: $input.password}
    } as $user
  
    function.run "core function/generate_magic_link" {
      input = {
        email: $user.email
        url  : $base_url|concat:"reset-password":"/"
      }
    } as $magic_link
  
    function.run sendgrid_dynamic_send {
      input = {
        template_id: "d-71228ad904de4eabb643854896a3e7e4"
        data       : {}|set:"first_name":$user.first_name|set:"verification_link":$magic_link
        to_email   : []|push:({}|set:"email":$user.email)
      }
    } as $sendgrid_notification
  }

  response = $user
  middleware = {pre: [{name: "validate_turnstile"}]}
}