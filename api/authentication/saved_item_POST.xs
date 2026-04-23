// Add saved item record
query saved_item verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "saved_item"
    }
  }

  stack {
    db.add saved_item {
      data = {created_at: "now"}
    } as $saved_item
  }

  response = $saved_item
}