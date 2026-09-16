// Logs all incoming requests and their responses for auditing
middleware create_request_log {
  input {
    json vars
    enum type {
      values = ["pre", "post"]
    }
  }

  stack {
    // We log during the POST phase to capture the status and result
    conditional {
      if ($input.type == "post") {
        // Extract context objects from vars
        var $req_ctx {
          value = $input.vars|get:"$request":{}
        }
      
        var $res_ctx {
          value = $input.vars|get:"$response":{}
        }
      
        var $auth_ctx {
          value = $input.vars|get:"$auth":{}
        }
      
        // Resolve User ID
        var $user_id {
          value = ($auth_ctx|get:"id") ?? ($input.vars|get:"$auth"|get:"id")
        }
      
        // Resolve Input
        var $input_data {
          value = ($req_ctx|get:"params") ?? ($req_ctx|get:"body") ?? ($req_ctx|get:"input")
        }
      
        // Resolve Output
        var $output_data {
          value = ($res_ctx|get:"result") ?? ($res_ctx|get:"output")
        }
      
        // Resolve Status
        var $req_status {
          value = ($res_ctx|get:"status") ?? ($input.vars|get:"$response"|get:"status")
        }
      
        // Use the centralized logging function
        function.run "core/log_request" {
          input = {
            endpoint   : $req_ctx|get:"uri"
            method     : $req_ctx|get:"method"
            status     : $req_status|to_int
            input_data : $input_data
            output_data: $output_data
            user_id    : $user_id|to_int
          }
        }
      }
    }
  }

  response = null
  response_strategy = "merge"
  exception_policy = "silent"
}