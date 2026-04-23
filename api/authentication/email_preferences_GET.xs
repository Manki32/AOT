// Query all Email Preferences records
query email_preferences verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query email_preference {
      return = {type: "list"}
    } as $email_preferences
  }

  response = $email_preferences
}