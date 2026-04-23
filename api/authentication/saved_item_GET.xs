// Query all saved item records
query saved_item verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query saved_item {
      return = {type: "list"}
    } as $saved_item
  }

  response = $saved_item
}