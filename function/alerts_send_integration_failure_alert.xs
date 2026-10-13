// Sends an internal admin alert email when an integration sync (HubSpot,
// Webflow, Packem) fails unexpectedly. Reads the recipient list from the
// matching env var based on `category`, then calls sendgrid_dynamic_send.
// Wrapped in try_catch so an alert failure never breaks the parent stack.
function "alerts/send_integration_failure_alert" {
  input {
    // Which recipient list to use: "business", "events", or "packem".
    text category filters=trim
  
    // Integration name shown as the badge/header: "HubSpot", "Webflow", "Packem".
    text integration filters=trim
  
    // Short title describing the failure (used in subject + heading).
    text event_type filters=trim
  
    // Plain-English explanation of what went wrong and the business impact.
    text what_went_wrong filters=trim
  
    // Where the data was coming from, e.g. "Xano".
    text source filters=trim
  
    // Where the data was going, e.g. "Webflow", "HubSpot", "Packem".
    text destination filters=trim
  
    // Human-readable name of the listing / order (optional).
    text? listing_name? filters=trim
  
    // Internal Xano id for the listing / order (optional).
    int? listing_id?
  
    // The outbound endpoint URL that failed (optional).
    text? endpoint? filters=trim
  
    // HTTP status code returned by the integration (optional).
    int? status_code?
  
    // Verbatim server error body / message (optional).
    json raw_error?
  }

  stack {
    try_catch {
      try {
        // Normalize category to lowercase for the switch below.
        var $cat {
          value = $input.category|to_lower
        }
      
        // Resolve recipient list based on category.
        var $recipients_raw {
          value = ""
        }
      
        switch ($cat) {
          case ("business") {
            var.update $recipients_raw {
              value = ($env.alert_recipients_business ?? "")
            }
          } break
        
          case ("events") {
            var.update $recipients_raw {
              value = ($env.alert_recipients_events ?? "")
            }
          } break
        
          case ("packem") {
            var.update $recipients_raw {
              value = ($env.alert_recipients_packem ?? "")
            }
          } break
        }
      
        // Bail silently if no recipients are configured for this category.
        precondition (($recipients_raw|trim) != "") {
          error = "No recipients configured for category"
        }
      
        // Build the to_email array of { email } objects, one per recipient.
        var $to_email {
          value = $recipients_raw
            |split:","
            |lambda_map:"return { email: $this.trim() };"
        }
      
        // Build the dynamic template data payload.
        var $data {
          value = {
            integration    : $input.integration
            event_type     : $input.event_type
            severity       : "error"
            what_went_wrong: $input.what_went_wrong
            listing_name   : ($input.listing_name ?? "")
            listing_id     : ($input.listing_id ?? 0)
            source         : $input.source
            destination    : $input.destination
            endpoint       : ($input.endpoint ?? "")
            status_code    : ($input.status_code ?? 0)
            raw_error      : ($input.raw_error ?? {})
            occurred_at    : now
            environment    : (($env.$branch ?? "") ~ " / " ~ ($env.$datasource ?? ""))
          }
        }
      
        // Send the alert via the existing SendGrid helper.
        function.run sendgrid_dynamic_send {
          input = {
            template_id: "d-90200050c0ca42aba7955d428c6f696f"
            data       : $data
            to_email   : $to_email
          }
        } as $sendgrid_result
      }
    
      catch {
        // Swallow any failure - never break the parent stack because the
        // alert email itself failed to send.
        debug.log {
          value = "send_integration_failure_alert: swallowed error"
        }
      }
    }
  }

  response = null
}