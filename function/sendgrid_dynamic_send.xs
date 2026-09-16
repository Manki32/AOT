// Send an email via Sendgrid using a dynamic template.
function sendgrid_dynamic_send {
  input {
    // The sendgrid template ID
    text template_id
  
    json data?
  
    // The email address to send the email
    object[] to_email? {
      schema {
        text email filters=trim
      }
    }
  }

  stack {
    precondition (($env.sendgrid_api_key ?? "") != "") {
      error = 'Please set your "sendgrid_api_key" environment variable.'
    }
  
    precondition (($env.sendgrid_from_email ?? "") != "") {
      error = 'Please set your "sendgrid_from_email" environment variable.'
    }
  
    // Makes an API request to SendGrid to send an email through a template
    api.request {
      url = "https://api.sendgrid.com/v3/mail/send"
      method = "POST"
      params = {}
        |set:"from":({}
          |set:"email":$env.sendgrid_from_email
          |set:"name":"Visitarizona.com"
        )
        |set:"personalizations":([]
          |push:({}
            |set:"to":$input.to_email
            |set:"dynamic_template_data":$input.data
          )
        )
        |set:"template_id":$input.template_id
      headers = []
        |push:"Content-Type: application/json"
        |push:("Authorization: Bearer %s"|sprintf:$env.sendgrid_api_key)
      verify_host = false
      verify_peer = false
    } as $api_result
  
    // Log the outbound request
    function.run "core/log_request" {
      input = {
        endpoint   : "https://api.sendgrid.com/v3/mail/send"
        method     : "POST"
        status     : $api_result.response.status|to_int
        input_data : "{}"
        output_data: $api_result.response.result
        user_id    : 0
      }
    }
  
    precondition ($api_result.response.status == 202) {
      error = $api_result.response.result.errors|first|get:"message"
    }
  }

  response = $api_result
}