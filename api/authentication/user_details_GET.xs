// Query all user details records
query user_details verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query user_detail {
      return = {type: "list"}
    } as $user_details
  }

  response = $user_details
}