// Edit logs record
query "logs/{logs_id}" verb=PATCH {
  api_group = "Default"

  input {
    int logs_id? filters=min:1
    dblink {
      table = "logs"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch logs {
      field_name = "id"
      field_value = $input.logs_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $logs
  }

  response = $logs
}