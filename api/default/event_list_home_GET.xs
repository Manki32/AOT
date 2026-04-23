// Query all event records
query "event/list/home" verb=GET {
  api_group = "Default"
  auth = "user"

  input {
  }

  stack {
    db.query event {
      where = $auth.id in $db.event.user_id
      sort = {event.created_at: "desc"}
      return = {type: "list"}
      output = ["id", "name", "status", "start_date", "end_date", "main_image_url"]
    } as $events
  }

  response = $events|slice:0:10
}