middleware create_request_log {
  input {
    json vars
    enum type {
      values = ["pre", "post"]
    }
  }

  stack {
  }

  response = null
  response_strategy = "merge"
  exception_policy = "silent"
}