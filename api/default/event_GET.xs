// Get event information as owner
query event verb=GET {
  api_group = "Default"
  auth = "user"

  input {
    int event_id? {
      table = "event"
    }
  }

  stack {
    db.get event {
      field_name = "id"
      field_value = $input.event_id
    } as $event
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["role"]
    } as $user
  
    api.lambda {
      code = """
        const event_listing = $var.event;
        const auth_id = $auth.id;
        
        const user_id_field = event_listing.user_id;
        
        // Check if user_id_field is an array and includes the auth_id
        if (Array.isArray(user_id_field)) {
          return user_id_field.includes(auth_id);
        }
        
        return false
        """
      timeout = 10
    } as $user_has_access
  
    precondition ($user_has_access || $user.role == "Admin") {
      error = "You don't have permission to access this event."
    }
  
    api.lambda {
      code = """
        const toDateTimeLocalString = (timestamp) => {
            if (timestamp === null || timestamp === undefined || isNaN(Number(timestamp))) {
                return null;
            }
        
            const date = new Date(Number(timestamp));
        
            if (isNaN(date.getTime())) {
                return null;
            }
        
            const pad = (num) => num.toString().padStart(2, '0');
        
            const year = date.getFullYear();
            const month = pad(date.getMonth() + 1); 
            const day = pad(date.getDate());
            const hours = pad(date.getHours());
            const minutes = pad(date.getMinutes());
        
            return `${year}-${month}-${day}T${hours}:${minutes}`;
        };
        
        const fromString = toDateTimeLocalString($var.event.from_timestamp);
        const toString = toDateTimeLocalString($var.event.to_timestamp);
        
        return {
            'from': fromString,
            'to': toString
        };
        """
      timeout = 10
    } as $dates
  }

  response = $event
    |set:"from_timestamp":$dates.from
    |set:"to_timestamp":$dates.to
  tags = ["new"]
}