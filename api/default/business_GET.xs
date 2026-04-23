// Get business information as owner
query business verb=GET {
  api_group = "Default"
  auth = "user"

  input {
    int business_listing_id? {
      table = "business_listing"
    }
  }

  stack {
    db.get business_listing {
      field_name = "id"
      field_value = $input.business_listing_id
      output = [
        "title"
        "owner_id"
        "user_id"
        "body_content"
        "editor_js_json"
        "amenities"
        "working_hours"
        "website"
        "email"
        "main_photo_url"
        "address_string"
        "latitude"
        "longitude"
        "status"
        "facebook_url"
        "youtube_url"
        "twitter_url"
        "instagram_url"
        "pinterest_url"
        "tripadvisor_id"
        "contact_phone"
        "address.name"
        "address.street"
        "address.street2"
        "address.city"
        "address.region"
        "address.postalCode"
        "address.country"
        "address.countryName"
        "photo_urls.url"
      ]
    } as $business_listing
  
    db.get user {
      field_name = "id"
      field_value = $auth.id
      output = ["role"]
    } as $user
  
    api.lambda {
      code = """
        const business_listing = $var.business_listing;
        const auth_id = $auth.id;
        
        const user_id_field = business_listing.user_id;
        
        // Check if user_id_field is an array and includes the auth_id
        if (Array.isArray(user_id_field)) {
          return user_id_field.includes(auth_id);
        }
        
        return false
        """
      timeout = 10
    } as $user_has_access
  
    precondition ($user_has_access || $user.role == "Admin") {
      error_type = "unauthorized"
      error = "You don't have permission to access this business."
    }
  
    db.query amenity {
      where = $db.amenity.id in $business_listing.amenities
      return = {type: "list"}
      output = ["name"]
    } as $amenities
  }

  response = $business_listing
    |set:"business_amenities":$amenities
}