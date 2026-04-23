query "auth/verify-account" verb=POST {
  api_group = "Authentication - New"
  auth = "user"

  input {
  }

  stack {
    db.edit user {
      field_name = "id"
      field_value = $auth.id
      data = {email_confirmed: true}
      addon = [
        {
          name  : "user_details_of_user"
          output: ["onboarding_complete"]
          input : {user_id: $output.id}
          as    : "details"
        }
      ]
    } as $user
  }

  response = $user
}