// Delete Email Preferences record.
query "email_preferences/{email_preferences_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int email_preferences_id? filters=min:1
  }

  stack {
    db.del email_preference {
      field_name = "id"
      field_value = $input.email_preferences_id
    }
  }

  response = null
}