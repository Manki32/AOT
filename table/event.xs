table event {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    text name? filters=trim
    text description? filters=trim
    text wf_id? filters=trim
    bool featured?
    text hs_id? filters=trim
    image? main_image?
    image[]? more_images?
    object[] photos? {
      schema {
        text index? filters=trim
        text category? filters=trim
        text url? filters=trim
        text alt_tag? filters=trim
        text title? filters=trim
      }
    }
  
    int[] old_event_categories? {
      table = "event_category"
    }
  
    int[] categories? {
      table = "category"
    }
  
    text? latitude?
    text? longitude?
    text contact_first_name? filters=trim
    text contact_last_name? filters=trim
    email contact_email? filters=trim|lower
    int owner_id? {
      table = "user"
    }
  
    int[] user_id? {
      table = "user"
    }
  
    int last_edit_by? {
      table = "user"
    }
  
    text slug? filters=trim
    object[] address? {
      schema {
        text name? filters=trim
        text street? filters=trim
        text street2? filters=trim
        text city? filters=trim
        text region? filters=trim
        text postalCode? filters=trim
      }
    }
  
    text attendance? filters=trim
    text date_last_merge? filters=trim
    text web_url? filters=trim
    text ticket_url? filters=trim
    text facebook_url? filters=trim
    text x_url? filters=trim
    text video_url? filters=trim
    text private_phone? filters=trim
    email private_email? filters=trim|lower
    text hubspot_record_id? filters=trim
    enum status? {
      values = [
        "Draft"
        "Requesting approval"
        "Approved"
        "Rejected"
        "Archived"
      ]
    }
  
    // Specific post or publication date for the event listing.
    date post_date?
  
    // The start date and time of the event.
    date start_date?
  
    // The end date and time of the event.
    date end_date?
  
    // A score or ranking associated with the event.
    int score?
  
    // Temporary identifier from an external system.
    text temp_id? filters=trim
  
    // Identifier for a draft version of the event.
    text draft_id? filters=trim
  
    // Identifier for a revision of the event.
    text revision_id? filters=trim
  
    // Indicates if the event listing is a provisional draft.
    bool is_provisional_draft?
  
    // Public URL for the event page.
    text url? filters=trim
  
    // Name of the event location or venue.
    text location_name? filters=trim
  
    // Operating hours for the event venue or related partner.
    text partner_hours? filters=trim
  
    // Details on event admission (e.g., Free, Ticketed).
    text event_admission? filters=trim
  
    // References to related business listings or partners.
    int[] related_partners? {
      table = "business_listing"
    }
  
    // References to associated partner regions.
    int[] partner_regions? {
      table = "places_cities_and_towns"
    }
  
    // Public contact phone number for the event.
    text contact_phone? filters=trim
  
    // URL for the event's Twitter (X) profile.
    text twitter_url? filters=trim
  
    // Direct URL for purchasing event tickets.
    text event_ticket_url? filters=trim
  
    // URL for a related YouTube video from a partner.
    text partner_youtube_video_url? filters=trim
  
    // Internal contact first name for the event.
    text contact_first_name_internal? filters=trim
  
    // Internal contact last name for the event.
    text contact_last_name_internal? filters=trim
  
    // Internal contact phone number for the event.
    text contact_phone_internal? filters=trim
  
    // Internal contact email address for the event.
    email contact_email_internal? filters=trim|lower
  
    text main_image_url? filters=trim
    text instagram_url? filters=trim
    text pinterest_url? filters=trim
    text tripadvisor_id? filters=trim
    json editor_js_json?
    int[] highlight_tags? {
      table = "tag"
    }
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}