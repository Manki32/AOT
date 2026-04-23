// Add Email Preferences record
query email_preferences verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "email_preference"
    }
  }

  stack {
    db.add email_preference {
      data = {created_at: "now"}
    } as $email_preferences
  }

  response = $email_preferences
}