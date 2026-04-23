// Get all amenities
query amenities verb=GET {
  api_group = "Default"
  auth = "user"

  input {
  }

  stack {
    db.query amenity {
      return = {type: "list"}
    } as $amenities
  }

  response = $amenities
  tags = ["new"]
}