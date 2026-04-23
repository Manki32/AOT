// Query all event records
query "event/list" verb=GET {
  api_group = "Default"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["role"]
    } as $user
  
    conditional {
      if ($user.role == "Admin") {
        db.query event {
          sort = {event.created_at: "desc"}
          return = {type: "list"}
          output = ["id", "name", "status", "start_date", "end_date", "main_image_url"]
        } as $events
      }
    
      else {
        db.query event {
          where = $auth.id in $db.event.user_id
          sort = {event.created_at: "desc"}
          return = {type: "list"}
          output = ["id", "name", "status", "start_date", "end_date", "main_image_url"]
        } as $events
      }
    }
  }

  response = $events
}