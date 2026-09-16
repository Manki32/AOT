// Delete logs record.
query "logs/{logs_id}" verb=DELETE {
  api_group = "Default"

  input {
    int logs_id? filters=min:1
  }

  stack {
    db.del logs {
      field_name = "id"
      field_value = $input.logs_id
    }
  }

  response = null
}