// Validate Cloudflare's Turnstile token
middleware validate_turnstile {
  input {
    json vars
    enum type {
      values = ["pre", "post"]
    }
  }

  stack {
    api.request {
      url = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
      method = "POST"
      params = {}
        |set:"secret":$env.turnstile_secret
        |set:"response":$input.vars.turnstile
    } as $api1
  
    precondition ($api1.response.result.success) {
      error_type = "unauthorized"
      error = "Verification expired or missing. Please refresh the page and try again."
      payload = $api1.response.result["error-codes"]
    }
  }

  response = $input.vars
  response_strategy = "replace"
  exception_policy = "critical"
}