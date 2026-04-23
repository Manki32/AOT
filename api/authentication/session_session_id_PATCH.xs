// Edit session record
query "session/{session_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int session_id? filters=min:1
    dblink {
      table = "session"
    }
  }

  stack {
    db.edit session {
      field_name = "id"
      field_value = $input.session_id
      data = {}
    } as $session
  }

  response = $session
}