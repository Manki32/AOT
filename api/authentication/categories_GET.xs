query categories verb=GET {
  api_group = "Authentication"

  input {
  }

  stack {
    db.query category {
      return = {type: "list"}
    } as $model
  }

  response = $model
  cache = {
    ttl       : 604800
    input     : true
    auth      : true
    datasource: true
    ip        : false
    headers   : []
    env       : []
  }
}