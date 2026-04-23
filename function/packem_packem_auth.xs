function "Packem/packem_auth" {
  input {
    bool force_refresh?
  }

  stack {
    group {
      stack {
        var $token {
          value = ""
        }
      
        redis.get {
          key = "packem_token"
        } as $cached_token
      
        conditional {
          if ($cached_token == false || $input.force_refresh) {
            api.request {
              url = "https://external.packem-wms.com/api/Auth/generateAccessToken"
              method = "POST"
              params = {}
                |set:"apiKey":$env.packem_api_key
                |set:"apiSecret":$env.packem_secret_key
              headers = []
                |push:"content-type: application/*+json"
            } as $api1
          
            precondition ($api1.response.status == 200) {
              error_type = "accessdenied"
              error = "Access Denied"
              payload = $api1.response
            }
          
            redis.set {
              key = "packem_token"
              data = $api1.response.result
              ttl = 17700
            }
          
            var.update $token {
              value = $api1.response.result
            }
          }
        
          else {
            var.update $token {
              value = $cached_token
            }
          }
        }
      }
    }
  }

  response = $token
}