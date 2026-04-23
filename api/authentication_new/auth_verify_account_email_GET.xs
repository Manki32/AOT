// Sends magic link to verify account
query "auth/verify-account-email" verb=GET {
  api_group = "Authentication - New"
  auth = "user"

  input {
  }

  stack {
    function.run "core function/base_url" {
      input = {environment: $env.$http_headers["X-Data-Source"]}
    } as $base_url
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["first_name", "last_name", "email"]
    } as $user
  
    function.run "core function/generate_magic_link" {
      input = {
        email: $user.email
        url  : $base_url|concat:"verifying-your-account":"/"
      }
    } as $magic_link
  
    function.run sendgrid_dynamic_send {
      input = {
        template_id: "d-286edb08204745ba894403c2747264f7"
        data       : {}|set:"first_name":$user.first_name|set:"verification_link":$magic_link
        to_email   : []|push:({}|set:"email":$user.email)
      }
    } as $sendgrid_email
  }

  response = $sendgrid_email
}