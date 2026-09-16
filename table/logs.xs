table logs {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // The API endpoint that was called.
    text endpoint? filters=trim
  
    // The HTTP method used for the endpoint call (e.g., GET, POST).
    text method? filters=trim
  
    // The HTTP status code of the response.
    int status?
  
    // The input payload or parameters sent to the endpoint.
    json input?
  
    // The output or response received from the endpoint.
    json output?
  
    // Reference to the user who made the request, if available.
    int user_id? {
      table = "user"
    }
  
    // The duration of the endpoint call in milliseconds.
    int duration?
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}