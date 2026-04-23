// Query all session records
query session verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query session {
      return = {type: "list"}
    } as $session
  }

  response = $session
}