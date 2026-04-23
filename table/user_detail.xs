table user_detail {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text address? filters=trim
  
    // If favorites have been saved, before a user is created
    int session_id? {
      table = "session"
    }
  
    text? hubspot_record_id?
    int user_id? {
      table = "user"
    }
  
    int[] interests? {
      table = "category"
    }
  
    int[] email_preferences? {
      table = "email_preference"
    }
  
    bool onboarding_complete?
    image? profile_image?
    enum[] activities? {
      values = ["discover_arizona", "business_listing", "event_listing"]
    }
  
    text[] companies? filters=trim
    text phone? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}