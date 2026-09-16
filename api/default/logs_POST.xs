// Add logs record
query logs verb=POST {
  api_group = "Default"

  input {
    dblink {
      table = "logs"
    }
  }

  stack {
    db.add logs {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $logs
  }

  response = $logs
}