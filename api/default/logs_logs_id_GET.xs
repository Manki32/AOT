// Get logs record
query "logs/{logs_id}" verb=GET {
  api_group = "Default"

  input {
    int logs_id? filters=min:1
  }

  stack {
    db.get logs {
      field_name = "id"
      field_value = $input.logs_id
    } as $logs
  
    precondition ($logs != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $logs
}