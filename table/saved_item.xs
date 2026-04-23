table saved_item {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    int business_listing_id? {
      table = "business_listing_raw_data"
    }
  
    int event_id? {
      table = "event"
    }
  
    int user_id? {
      table = "user"
    }
  
    int session_id? {
      table = "session"
    }
  
    int blog_id? {
      table = ""
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}