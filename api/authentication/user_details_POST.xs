// Add user details record
query user_details verb=POST {
  api_group = "Authentication"

  input {
    dblink {
      table = "user_detail"
    }
  }

  stack {
    db.add user_detail {
      data = {created_at: "now"}
    } as $user_details
  }

  response = $user_details
}