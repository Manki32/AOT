// Get saved item record
query "saved_item/{saved_item_id}" verb=GET {
  api_group = "Authentication"

  input {
    int saved_item_id? filters=min:1
  }

  stack {
    db.get saved_item {
      field_name = "id"
      field_value = $input.saved_item_id
    } as $saved_item
  
    precondition ($saved_item != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $saved_item
}