// Get the correct base url for production or staging
function "core function/base_url" {
  input {
    enum environment? {
      values = ["live", "test"]
    }
  }

  stack {
    conditional {
      if ($input.environment == "live") {
        var $url {
          value = $env.production_base_url
        }
      }
    
      else {
        var $url {
          value = $env.staging_base_url
        }
      }
    }
  }

  response = $url
  tags = ["new"]
  history = "all"
}