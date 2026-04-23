addon tag_item {
  input {
    int tag_id? {
      table = "tag"
    }
  }

  stack {
    db.query tag {
      where = $db.tag.id == $input.tag_id
      return = {type: "single"}
    }
  }
}