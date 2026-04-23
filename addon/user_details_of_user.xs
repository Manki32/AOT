addon user_details_of_user {
  input {
    int user_id? {
      table = "user"
    }
  }

  stack {
    db.query user_detail {
      where = $db.user_detail.user_id == $input.user_id
      return = {type: "single"}
    }
  }
}