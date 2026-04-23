// Add event record
query "event/duplicate" verb=POST {
  api_group = "Default"
  auth = "user"

  input {
    int id?
  }

  stack {
    db.get user {
      field_name = "id"
      field_value = $auth.id
    } as $user1
  
    db.get event {
      field_name = "id"
      field_value = $input.id
    } as $event
  
    precondition (($auth.id|in:$event.user_id) === true || $user1.role === "Admin") {
      error = "You don't have the permissions to duplicate this record"
      payload = "You don't have the permissions to duplicate this record"
    }
  
    db.add event {
      data = {
        created_at                 : "now"
        name                       : $event.name|concat:" COPY":""
        description                : $event.description
        old_event_categories       : $event.old_event_categories
        categories                 : $event.categories
        latitude                   : $event.latitude
        longitude                  : $event.longitude
        contact_first_name         : $event.contact_first_name
        contact_last_name          : $event.contact_last_name
        contact_email              : $event.contact_email
        owner_id                   : $event.owner_id
        user_id                    : $event.user_id
        last_edit_by               : $event.last_edit_by
        attendance                 : $event.attendance
        date_last_merge            : $event.date_last_merge
        hours_to                   : $event.hours_to
        web_url                    : $event.web_url
        ticket_url                 : $event.ticket_url
        facebook_url               : $event.facebook_url
        x_url                      : $event.x_url
        video_url                  : $event.video_url
        private_phone              : $event.private_phone
        private_email              : $event.private_email
        status                     : $event.status
        post_date                  : $event.post_date
        start_date                 : $event.start_date
        end_date                   : $event.end_date
        all_day                    : $event.all_day
        rrule                      : $event.rrule
        freq                       : $event.freq
        interval                   : $event.interval
        count                      : $event.count
        until                      : $event.until
        by_month                   : $event.by_month
        by_year_day                : $event.by_year_day
        by_month_day               : $event.by_month_day
        by_day                     : $event.by_day
        score                      : $event.score
        temp_id                    : $event.temp_id
        draft_id                   : $event.draft_id
        revision_id                : $event.revision_id
        is_provisional_draft       : true
        url                        : $event.url
        location_name              : $event.location_name
        partner_hours              : $event.partner_hours
        event_admission            : $event.event_admission
        related_partners           : $event.related_partners
        partner_regions            : $event.partner_regions
        contact_phone              : $event.contact_phone
        twitter_url                : $event.twitter_url
        event_ticket_url           : $event.event_ticket_url
        partner_youtube_video_url  : $event.partner_youtube_video_url
        contact_first_name_internal: $event.contact_first_name_internal
        contact_last_name_internal : $event.contact_last_name_internal
        contact_phone_internal     : $event.contact_phone_internal
        contact_email_internal     : $event.contact_email_internal
        main_image_url             : $event.main_image_url
        instagram_url              : $event.instagram_url
        pinterest_url              : $event.pinterest_url
        tripadvisor_id             : $event.tripadvisor_id
        editor_js_json             : $event.editor_js_json
        from_timestamp             : $event.from_timestamp
        to_timestamp               : $event.to_timestamp
        main_image                 : $event.main_image
        more_images                : $event.more_images
        photos                     : $event.photos
        address                    : $event.address
      }
    
      output = ["id"]
    } as $model
  }

  response = $model
}