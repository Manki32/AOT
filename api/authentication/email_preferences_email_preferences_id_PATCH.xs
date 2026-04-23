// Edit Email Preferences record
query "email_preferences/{email_preferences_id}" verb=PATCH {
  api_group = "Authentication"

  input {
    int email_preferences_id? filters=min:1
    dblink {
      table = "email_preference"
    }
  }

  stack {
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $raw_input
  
    db.patch email_preference {
      field_name = "id"
      field_value = $input.email_preferences_id
      data = `$input|pick:($raw_input|keys)`|filter_null|filter_empty_text
    } as $email_preferences
  }

  response = $email_preferences
}