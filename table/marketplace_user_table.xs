// Users database
table marketplace_user_table {
  auth = true

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text first_name? filters=trim
    text last_name? filters=trim
    email email?
    password password? filters=min:8|minDigit:1|minSymbol:1 {
      visibility = "internal"
    }
  
    bool verified?
    object magic_reset_password? {
      schema {
        text token? filters=trim
        timestamp? expiration?
        bool used?
      }
    }
  
    object magic_verify_email? {
      schema {
        text token? filters=trim
        timestamp? expiration?
        bool used?
        text new_email? filters=trim
      }
    }
  
    object google_oauth? {
      schema {
        text id? filters=trim
        text name? filters=trim
        email email?
      }
    }
  
    timestamp? last_login?
    bool deleted?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["exploration"]
}