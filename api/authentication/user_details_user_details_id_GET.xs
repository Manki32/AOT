// Get user details record
query "user_details/{user_details_id}" verb=GET {
  api_group = "Authentication"

  input {
    int user_details_id? filters=min:1
  }

  stack {
    db.get user_detail {
      field_name = "id"
      field_value = $input.user_details_id
    } as $user_details
  
    precondition ($user_details != null) {
      error_type = "notfound"
      error = "Not Found."
    }
  }

  response = $user_details
}