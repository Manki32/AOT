query "user/{user_id}" verb=PUT {
  api_group = "Authentication"
  auth = "user"

  input {
    int? user_id? filters=min:1
    text password
    text new_password filters=trim
    text confirm_new_password filters=trim
  }

  stack {
    precondition ($auth.id == $input.user_id) {
      error_type = "unauthorized"
      error = "Unatuhorized: You're not allowed to edit this record"
      payload = "Unauthorized: You're not allowed to edit this record"
    }
  
    db.get user {
      field_name = "id"
      field_value = $input.user_id
      output = [
        "id"
        "created_at"
        "first_name"
        "last_name"
        "email"
        "password"
        "email_confirmed"
        "role"
      ]
    } as $user1
  
    !precondition ($user1.email_confirmed) {
      error = "Please verify your email first. You can't change your password until you verify your email. "
      payload = "Please verify your email first. You can't change your password until you verify your email. "
    }
  
    security.check_password {
      text_password = $input.password
      hash_password = $user1.password
    } as $password_valid
  
    precondition ($password_valid) {
      error_type = "unauthorized"
      error = "Invalid password"
      payload = "Your current password is not correct. Please try again. "
    }
  
    precondition ($input.new_password == $input.confirm_new_password) {
      error_type = "inputerror"
      error = "Passwords aren't matching"
      payload = "Password confirmation failed. Your passwords aren't matching"
    }
  
    db.edit user {
      field_name = "id"
      field_value = $input.user_id
      data = {
        first_name     : $user1.first_name
        last_name      : $user1.last_name
        email          : $user1.email
        password       : $input.new_password
        email_confirmed: $user1.email_confirmed
        role           : $user1.role
      }
    } as $model
  }

  response = $model
}