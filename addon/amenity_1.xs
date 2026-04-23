addon amenity_1 {
  input {
    int amenity_id? {
      table = "amenity"
    }
  }

  stack {
    db.query amenity {
      where = $db.amenity.id == $input.amenity_id
      return = {type: "single"}
    }
  }
}