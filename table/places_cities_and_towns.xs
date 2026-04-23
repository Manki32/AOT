table places_cities_and_towns {
  auth = false

  schema {
    int id
    text title?
    text slug?
    int level?
    int parent? {
      table = "places_cities_and_towns"
    }
  
    text wf_id? filters=trim
    int region_id? {
      table = "places_regions"
    }
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}