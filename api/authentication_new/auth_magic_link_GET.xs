// Endpoint for requesting magic link
query "auth/magic-link" verb=GET {
  api_group = "Authentication - New"

  input {
    email email?
    text turnstile? filters=trim
  }

  stack {
    function.run "core function/base_url" {
      input = {environment: $env.$http_headers["X-Data-Source"]}
    } as $base_url
  
    function.run "core function/generate_magic_link" {
      input = {
        email: $input.email
        url  : $base_url|concat:"reset-password":"/"
      }
    } as $magic_link
  
    precondition ($magic_link != null) {
      error = "Magic link could not be created. Try again."
    }
  
    db.get user {
      field_name = "email"
      field_value = $input.email|to_lower
      output = ["first_name"]
    } as $user
  
    function.run sendgrid_dynamic_send {
      input = {
        template_id: "d-ce795a566666499f8f2a3ce42b3bb23e"
        data       : {}|set:"verification_link":$magic_link|set:"first_name":$user.first_name
        to_email   : []|push:({}|set:"email":$input.email)
      }
    } as $sendgrid_send_magic_link
  }

  response = {
    message: {}|set:"success":true|set:"message":"magic link sent"
  }

  middleware = {pre: [{name: "validate_turnstile"}]}
}