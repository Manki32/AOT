// Get all businesses
query "business/list" verb=GET {
  api_group = "Default"
  auth = "user"

  input {
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["role"]
    } as $user
  
    conditional {
      if ($user.role == "Admin") {
        db.query business_listing {
          sort = {business_listing.created_at: "desc"}
          return = {type: "list"}
          output = ["id", "title", "main_photo_url", "status"]
        } as $business_listings
      }
    
      else {
        db.query business_listing {
          where = $auth.id in $db.business_listing.user_id
          sort = {business_listing.created_at: "desc"}
          return = {type: "list"}
          output = ["id", "title", "main_photo_url", "status"]
        } as $business_listings
      }
    }
  }

  response = $business_listings
  tags = ["new"]
}