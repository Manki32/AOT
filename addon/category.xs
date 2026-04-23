addon category {
  input {
    int category_id? {
      table = "category"
    }
  }

  stack {
    db.query category {
      where = $db.category.id == $input.category_id
      return = {type: "single"}
    }
  }
}