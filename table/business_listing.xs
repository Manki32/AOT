// Cleaned up business listing data
table business_listing {
  auth = false

  schema {
    int id
    int[] old_ids? {
      table = "business_listing_raw_data"
    }
  
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text title? filters=trim
  
    // A URL-friendly slug for the listing.
    text slug? filters=trim
  
    int owner_id? {
      table = "user"
    }
  
    int[] user_id? {
      table = "user"
    }
  
    text hs_id? filters=trim
    text summary? filters=trim
    text body_content? filters=trim
    json editor_js_json?
    text wf_item_id? filters=trim
    bool push_to_wf_cms?=true
    bool wf_synced?
    bool wf_fail?
    int category_id? {
      table = "category"
    }
  
    int[] tag_id? {
      table = "tag"
    }
  
    int[] amenities? {
      table = "amenity"
    }
  
    int last_edit_by? {
      table = "user"
    }
  
    text working_hours? filters=trim
    object address? {
      schema {
        text name? filters=trim
        text street? filters=trim
        text street2? filters=trim
        text city? filters=trim
        text region? filters=trim
        text postalCode? filters=trim
        text country? filters=trim
        text countryName? filters=trim
      }
    }
  
    text website? filters=trim
    email email? filters=trim|lower
    email missing_email? filters=trim|lower
    image? hero_image?
    image[]? more_images?
    text main_photo_url? filters=trim
    object[]? photo_urls? {
      schema {
        int index?
        text category? filters=trim
        text url? filters=trim
        text alt? filters=trim
        text title? filters=trim
      }
    }
  
    text address_string? filters=trim
    text latitude? filters=trim
    text longitude? filters=trim
    enum status? {
      values = [
        "Approved"
        "Rejected"
        "Draft"
        "Requesting Approval"
        "Archived"
      ]
    }
  
    // URL for the business's Facebook page
    text facebook_url? filters=trim
  
    // URL for the business's YouTube channel
    text youtube_url? filters=trim
  
    // URL for the business's Twitter (X) profile
    text twitter_url? filters=trim
  
    // URL for the business's Instagram profile
    text instagram_url? filters=trim
  
    // URL for the business's Pinterest profile
    text pinterest_url? filters=trim
  
    // Tripadvisor listing ID
    text tripadvisor_id? filters=trim
  
    // Specific publication or post date for the listing.
    date post_date?
  
    // Temporary identifier from an external system.
    text temp_id? filters=trim
  
    // Identifier for a draft version.
    text draft_id? filters=trim
  
    // Identifier for a revision.
    text revision_id? filters=trim
  
    // Indicates if the listing is a provisional draft.
    bool provisional_draft?
  
    // Timestamp of the last update.
    timestamp date_updated?
  
    // Previous URL for the listing, for redirection purposes.
    text old_url? filters=trim
  
    int[] partner_regions? {
      table = "places_cities_and_towns"
    }
  
    // Contact phone number for the business.
    text contact_phone? filters=trim
  
    // Text used for searching/matching.
    text partner_search_term? filters=trim
  
    // Meta title for SEO.
    text meta_title? filters=trim
  
    // Meta description for SEO.
    text meta_description? filters=trim
  
    // Meta keywords for SEO.
    text meta_keywords? filters=trim
  
    // Meta image for social sharing and SEO.
    image meta_image?
  
    int s3_meta_image? {
      table = "s3_images"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["cleanup"]
}