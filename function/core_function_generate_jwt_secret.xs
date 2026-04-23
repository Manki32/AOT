// This admin function creates a jwt that then can be copied to your env variables.
function "core function/generate_jwt_secret" {
  input {
  }

  stack {
    security.create_secret_key {
      bits = 1024
      format = "object"
    } as $secret
  
    var $json_secret {
      value = $secret|json_encode
    }
  }

  response = $json_secret
}