// Get the user record belonging to the authentication token
query "auth/me" verb=GET {
  api_group = "Authentication - New"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = [
        "id"
        "created_at"
        "first_name"
        "last_name"
        "email"
        "email_confirmed"
        "role"
      ]
    
      addon = [
        {
          name  : "user_details_of_user"
          output: [
            "id"
            "interests"
            "email_preferences"
            "onboarding_complete"
            "profile_image.url"
          ]
          input : {user_id: $output.id}
          as    : "user_details"
        }
      ]
    } as $user
  }

  response = $user
}