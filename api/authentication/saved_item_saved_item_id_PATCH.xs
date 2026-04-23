// Edit saved item record
query "saved_item/{saved_item_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int saved_item_id? filters=min:1
    dblink {
      table = "saved_item"
    }
  }

  stack {
    db.edit saved_item {
      field_name = "id"
      field_value = $input.saved_item_id
      data = {}
    } as $saved_item
  }

  response = $saved_item
}