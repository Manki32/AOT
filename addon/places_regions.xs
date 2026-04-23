addon places_regions {
  input {
    int places_regions_id? {
      table = "places_regions"
    }
  }

  stack {
    db.query places_regions {
      where = $db.places_regions.id == $input.places_regions_id
      return = {type: "single"}
    }
  }
}