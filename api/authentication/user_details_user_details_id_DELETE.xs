// Delete user details record.
query "user_details/{user_details_id}" verb=DELETE {
  api_group = "Authentication"

  input {
    int user_details_id? filters=min:1
  }

  stack {
    db.del user_detail {
      field_name = "id"
      field_value = $input.user_details_id
    }
  }

  response = null
}