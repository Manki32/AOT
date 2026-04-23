addon related_partners {
  input {
    int business_listing_cleanup_id? {
      table = "business_listing"
    }
  }

  stack {
    db.query business_listing {
      where = $db.business_listing.id == $input.business_listing_cleanup_id
      return = {type: "single"}
    }
  }
}