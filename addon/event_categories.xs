addon event_categories {
  input {
    int event_categories_id? {
      table = "event_category"
    }
  }

  stack {
    db.query event_category {
      where = $db.event_category.id == $input.event_categories_id
      return = {type: "single"}
    }
  }
}