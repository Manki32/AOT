// Get Email Preferences record
query "email_preferences/{email_preferences_id}" verb=GET {
  api_group = "Authentication"

  input {
    int email_preferences_id? filters=min:1
  }

  stack {
    db.get email_preference {
      field_name = "id"
      field_value = $input.email_preferences_id
    } as $email_preferences
  
    precondition ($email_preferences != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $email_preferences
}