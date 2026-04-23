table event_category {
  auth = false

  schema {
    int id
    text Category?
    int category_id? {
      table = "category"
    }
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}