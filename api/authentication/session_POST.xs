// Add session record
query session verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "session"
    }
  }

  stack {
    db.add session {
      enforce_hidden_fields = false
      data = {created_at: "now"}
    } as $session
  }

  response = $session
}