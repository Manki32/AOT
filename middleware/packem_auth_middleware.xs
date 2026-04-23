// Get packem authentication token from cache or the packem API
middleware packem_auth_middleware {
  input {
    json vars
    enum type {
      values = ["pre", "post"]
    }
  }

  stack {
    var $vars {
      value = $input.vars
    }
  
    function.run "Packem/packem_auth" as $packem_auth_token
    var.update $vars {
      value = $input.vars
        |set:"packem_auth_token":$packem_auth_token
    }
  }

  response = $vars
  response_strategy = "merge"
  exception_policy = "critical"
}