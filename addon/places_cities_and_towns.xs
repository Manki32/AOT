addon places_cities_and_towns {
  input {
    int places_cities_and_towns_id? {
      table = "places_cities_and_towns"
    }
  }

  stack {
    db.query places_cities_and_towns {
      where = $db.places_cities_and_towns.id == $input.places_cities_and_towns_id
      return = {type: "single"}
    }
  }
}