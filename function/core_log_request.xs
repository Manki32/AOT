// Generic function to log any request/event to the logs table
function "core/log_request" {
  input {
    text endpoint
    text method
    int status
    json input_data?
    json output_data?
    int user_id?
  }

  stack {
    // Sanitize user_id
    var $resolved_user_id {
      value = $input.user_id
    }
  
    conditional {
      if (($resolved_user_id == 0) || ($resolved_user_id == null)) {
        // If not provided, try to fallback to the authenticated user in the current context
        var.update $resolved_user_id {
          value = ($auth.id ?? null)
        }
      }
    }
  
    // Add the log record
    db.add logs {
      data = {
        endpoint: $input.endpoint
        method  : $input.method
        status  : $input.status
        input   : $input.input_data
        output  : $input.output_data
        user_id : $resolved_user_id
      }
    } as $new_log
  }

  response = $new_log
}