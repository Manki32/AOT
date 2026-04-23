function "core function/generate_api_key" {
  input {
  }

  stack {
    security.create_secret_key {
      bits = 1024
      format = "object"
    } as $crypto1
  }

  response = $crypto1
}