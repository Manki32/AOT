// Delete saved item record.
query "saved_item/{saved_item_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int saved_item_id? filters=min:1
  }

  stack {
    db.del saved_item {
      field_name = "id"
      field_value = $input.saved_item_id
    }
  }

  response = null
}