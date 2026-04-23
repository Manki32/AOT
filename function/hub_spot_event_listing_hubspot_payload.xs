function "HubSpot/Event Listing -> Hubspot Payload" {
  input {
    json properties?
  }

  stack {
    api.lambda {
      code = """
        /*
        const eventItem = {
          id: '',
          created_at: '',
          name: '',
          description: '',
          wf_id: '',
          event_categories: [
            {
              id: '',
              Category: '',
              category_id: '',
              _category: {
                wf_id: '',
              },
            },
          ],
          latitude: '',
          longitude: '',
          contact_first_name: '',
          contact_last_name: '',
          contact_email: '',
          slug: '',
          attendance: '',
          date_last_merge: '',
          hours_to: '',
          web_url: '',
          ticket_url: '',
          facebook_url: '',
          x_url: '',
          video_url: '',
          private_phone: '',
          private_email: '',
          user_id: '',
          last_edit_by: '',
          hubspot_record_id: '',
          status: '',
          post_date: '',
          start_date: '',
          end_date: '',
          all_day: '',
          rrule: '',
          freq: '',
          interval: '',
          count: '',
          until: '',
          by_month: [''],
          by_year_day: [''],
          by_month_day: [''],
          by_day: [''],
          score: '',
          temp_id: '',
          draft_id: '',
          revision_id: '',
          is_provisional_draft: '',
          url: '',
          location_name: '',
          partner_hours: '',
          event_admission: '',
          related_partners: [
            {
              wf_item_id: '',
            },
          ],
          partner_regions: [
            {
              wf_id: '',
              region_id: '',
              _places_regions: {
                Item_ID: '',
              },
            },
          ],
          contact_phone: '',
          twitter_url: '',
          event_ticket_url: '',
          partner_youtube_video_url: '',
          contact_first_name_internal: '',
          contact_last_name_internal: '',
          contact_phone_internal: '',
          contact_email_internal: '',
          main_image: '',
          more_images: [],
          photos: [
            {
              index: '',
              category: '',
              url: '',
              alt_tag: '',
              title: '',
            },
          ],
          address: [
            {
              name: '',
              street: '',
              street2: '',
              city: '',
              region: '',
              postalCode: '',
            },
          ],
        };
        */
        
        const item = $input.properties; // change to eventItem to use as an interface
        
        const data = {
          //   account_type: '',
          event_address: item.address?.[0]?.street,
          event_address_2: item.address?.[0]?.street2,
          event_categories: item.categories?.map(cat => cat.name).join('; '),
          event_city: item.address?.[0]?.city,
          event_create_date__historical_: new Date(new Date(item.created_at).toISOString().split('T')[0]).getTime(),
          event_description: item.description,
          event_email: item.contact_email || '',
          event_end_date: item.end_date,
          event_estimated_attendance: item.attendance,
          event_facebook_page: item.facebook_url,
          //  event_flier_pdf_: '',
          event_hero_image: item.main_image_url || '',
          event_hours: item.partner_hours,
          event_latitude: item.latitude,
          event_location__general_name_: item.location_name,
          event_longitude: item.longitude,
          event_name: item.name,
          event_phone_number: item.contact_phone,
          event_photo_2: item.photos?.[2]?.url || '',
          event_photo_3: item.photos?.[3]?.url || '',
          event_photos: item.photos?.[1]?.url || '',
          event_postal_code: item.address?.[0]?.postalCode,
          event_price: item.event_admission,
          event_start_date: item.start_date,
          event_state: 'Arizona',
          event_ticket_information_page: item.ticket_url,
          event_video_url: item.partner_youtube_video_url,
          event_website: item.web_url,
          event_x_page: item.twitter_url,
          //   hs_all_accessible_team_ids: '',
          //   hs_all_assigned_business_unit_ids: '',
          //   hs_all_owner_ids: '',
          //   hs_all_team_ids: '',
          //   hs_created_by_user_id: '',
          //   hs_createdate: '',
          //   hs_lastmodifieddate: '',
          //   hs_merged_object_ids: '',
          //   hs_object_id: '',
          //  hs_owning_teams: '',
          //   hs_pinned_engagement_id: '',
          //   hs_read_only: '',
          //   hs_shared_team_ids: '',
          //   hs_shared_user_ids: '',
          //   hs_unique_creation_key: '',
          //   hs_updated_by_user_id: '',
          //   hs_user_ids_of_all_notification_followers: '',
          //   hs_user_ids_of_all_notification_unfollowers: '',
          //   hs_user_ids_of_all_owners: '',
          //   hs_was_imported: '',
          //   hubspot_owner_assigneddate: '',
          // hubspot_owner_id: item.user_id.user_details.name, 
          //   hubspot_team_id: '',
          live_url: `https://www.visitarizona.com/events/${item.slug}`,
          staging_url: `https://extranet.visitarizona.com/events-listings/event-listing-item?eventid=${item.id}`,
          status: item.status,
          xano_id: item.id,
          repeats: '',
          repeat_frequency: '',
          repeats_until: '',
          slug: '',
        
          /* Properties to add to HS: 
            partner_cities_and_towns,
            partner_region,
        */
        };
        
        const result = {};
        
        for (const key in data) {
          if (data[key]) {
            result[key] = data[key];
          }
        }
        
        const jsonResult = JSON.stringify(result);
        return jsonResult;
        """
      timeout = 10
    } as $properties_object
  }

  response = $properties_object
  history = 100
}