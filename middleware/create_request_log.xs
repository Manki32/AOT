// Logs all incoming requests and their responses for auditing
middleware create_request_log {
  input {
    json vars
    enum type {
      values = ["pre", "post"]
    }
  }

  stack {
    // We only want to log after the request has finished to capture status and output
    conditional {
      if ($input.type == "post") {
        // Capture user_id and handle the 0 (unauthenticated) case
        var $user_id {
          value = $input.vars|get:"$auth"|get:"id"
        }
      
        conditional {
          if (($user_id == 0) || ($user_id == null)) {
            var.update $user_id {
              value = null
            }
          }
        }
      
        // Add the log record to the database
        db.add logs {
          data = {
            endpoint: $input.vars|get:"$request"|get:"uri"
            method  : $input.vars|get:"$request"|get:"method"
            status  : $input.vars|get:"$response"|get:"status"
            input   : $input.vars|get:"$request"|get:"input"
            output  : $input.vars|get:"$response"|get:"output"
            user_id : $user_id
            duration: $input.vars|get:"$response"|get:"duration"
          }
        }
      }
    }
  }

  response = null
  response_strategy = "merge"
  exception_policy = "silent"
}