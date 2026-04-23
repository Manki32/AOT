// Edit User record
query "user/{user_id}" verb=PATCH {
  api_group = "Authentication"
  auth = "user"

  input {
    int user_id? filters=min:1
    dblink {
      table = "user"
      override = {
        role           : {hidden: true}
        password       : {hidden: true}
        email_confirmed: {hidden: true}
      }
    }
  }

  stack {
    precondition ($auth.id == $input.user_id) {
      error_type = "unauthorized"
      error = "Unauthorized: You're not allowed to edit this record"
      payload = "You're not allowed to edit this record"
    }
  
    util.get_raw_input {
      encoding = "json"
      exclude_middleware = false
    } as $x1
  
    db.patch user {
      field_name = "id"
      field_value = $input.user_id
      data = `$input|pick:($x1|keys)`
        |filter_null:""
        |filter_empty_text:""
    } as $user1
  }

  response = $user1
}