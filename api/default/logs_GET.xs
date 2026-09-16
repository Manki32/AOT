// Query all logs records
query logs verb=GET {
  api_group = "Default"

  input {
  }

  stack {
    db.query logs {
      return = {type: "list"}
    } as $logs
  }

  response = $logs
}