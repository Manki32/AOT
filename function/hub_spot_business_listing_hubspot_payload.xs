function "HubSpot/Business Listing -> Hubspot Payload" {
  input {
    json properties?
  }

  stack {
    api.lambda {
      code = """
        const item = $input.properties
        
        
        // Uncomment for autocompletion
        
        // const item = {
        //       "id": 735600,
        //       "old_ids": [],
        //       "created_at": 1687323902000,
        //       "title": "Bobby Q's Mesa",
        //       "slug": "bobby-qs-mesa",
        //       "summary": "Bobby Q BBQ Catering, you can trust and have confidence that your event will be memorable, stress free and undeniably delicious. From our scratch kitchen, to your event, you and your guests will revel in hand trimmed steaks, in-house smoked meats, homemade side dishes and delectable desserts. Never frozen, always fresh, your customized menu will have you savoring every bite. Special dietary restricted items are also available and just as delicious.",
        //       "body_content": "<p>Bobby Q BBQ Catering, you can trust and have confidence that your event will be memorable, stress free and undeniably delicious. From our scratch kitchen, to your event, you and your guests will revel in hand trimmed steaks, in-house smoked meats, homemade side dishes and delectable desserts. Never frozen, always fresh, your customized menu will have you savoring every bite. Special dietary restricted items are also available and just as delicious.</p>",
        //       "wf_item_id": "684f30754cb99a864f6072c2",
        //       "push_to_wf_cms": true,
        //       "wf_fail": false,
        //       "category_id": 0,
        //       "tag_id": [
        //         {
        //           "id": 783540,
        //           "name": "Restaurants & Bars",
        //           "slug": "restaurants-bars",
        //           "level": 2,
        //           "old_crm_id": 2076,
        //           "wf_id": "",
        //           "_category": {
        //             "name": "test"
        //           },
        //           "alt_tag": "Restaraunts"
        //         }
        //       ],
        //       "amenities": [
        //         {
        //           "id": 749807,
        //           "created_at": 1749635500790,
        //           "name": "Accessible",
        //           "slug": "accessible",
        //           "wf_id": "683e33942bea634d0522c65e"
        //         },
        //         {
        //           "id": 749808,
        //           "created_at": 1749635500792,
        //           "name": "Family Friendly",
        //           "slug": "family-friendly",
        //           "wf_id": "683e3394b1aed86e3637054c"
        //         },
        //         {
        //           "id": 749809,
        //           "created_at": 1749635500795,
        //           "name": "Parking Available",
        //           "slug": "parking-available",
        //           "wf_id": "683e3394aa455d35a4ca56a0"
        //         }
        //       ],
        //       "last_edit_by": 0,
        //       "working_hours": "",
        //       "website": "http://www.bobbyqbbq.com/mesa",
        //       "email": "matt.bobbyq@gmail.com",
        //       "hubspot_id": null,
        //       "main_photo_url": "",
        //       "latitude": "",
        //       "longitude": "",
        //       "status": "",
        //       "facebook_url": "",
        //       "youtube_url": "",
        //       "twitter_url": "",
        //       "instagram_url": "",
        //       "pinterest_url": "",
        //       "tripadvisor_id": "",
        //       "post_date": "2023-06-21",
        //       "temp_id": "",
        //       "draft_id": "",
        //       "revision_id": "",
        //       "provisional_draft": false,
        //       "date_updated": 1749597536000,
        //       "old_url": "https://www.visitarizona.com/directory/bobby-qs-mesa/",
        //       "partner_regions": [
        //         {
        //           "id": 89049,
        //           "title": "Mesa",
        //           "slug": "mesa",
        //           "level": 2,
        //           "parent": 88998,
        //           "wf_id": "68439d3bedcecf7649d38384",
        //           "region_id": 2
        //         },
        //         {
        //           "id": 89051,
        //           "title": "Phoenix",
        //           "slug": "phoenix",
        //           "level": 2,
        //           "parent": 88998,
        //           "wf_id": "683a4de1cd8fe3c5ba611ee3",
        //           "region_id": 2
        //         }
        //       ],
        //       "contact_phone": "1-480-361-7470",
        //       "partner_search_term": "Bobby Q's Mesa",
        //       "meta_title": "",
        //       "meta_description": "",
        //       "meta_keywords": "",
        //       "s3_meta_image": 0,
        //       "address": {
        //         "name": "",
        //         "street": "",
        //         "street2": "",
        //         "city": "",
        //         "region": "",
        //         "postalCode": "",
        //         "country": "",
        //         "countryName": ""
        //       },
        //       "hero_image": null,
        //       "more_images": null,
        //       "photo_urls": null,
        //       "meta_image": {
        //         "access": "public",
        //         "path": "",
        //         "name": "",
        //         "type": "",
        //         "size": 0,
        //         "mime": "",
        //         "meta": {}
        //       }
        //     }
        
        const data = {
            "instagram_url": item.instagram_url,
            "facebook_url": item.facebook_url,
            "youtube_url": item.youtube_url,
            "twitter_url": item.twitter_url,
            "pinterest_url": item.pinterest_url,
            "trip_advisor_id": item.tripadvisor_id,
            "amentities": item.amenities?.map(amenity => amenity.name).join("; "),
            "business_listing_categories": [...new Set(item.tag_id?.map(item => item?._category?.name).filter(name => name != null && name.trim() !== ""))].join("; "),
            "business_listing_description": item.body_content,
            "business_listing_title": item.title,
            "business_website": item.website,
            "company_name": item.title,
            "hero_image": item.main_photo_url,
            "highlight_tags":item.tag_id?.filter(tag => tag.wf_id && tag.wf_id.trim()).map(tag => tag.name).filter(name => name && name.trim() !== "").join("; "),
            "hubspot_owner_id": "",
            "hubspot_team_id": "",
            "last_edited_by": "",
            "staging_url": `https://extranet.visitarizona.com/business-listings/item?businessid=${item.id}`,
            "latitude": item.latitude,
            "longitude": item.longitude,
            "photo_1": Array.isArray(item.photo_urls) && item.photo_urls[1]?.url ? item.photo_urls[1].url : "",
            "photo_2": Array.isArray(item.photo_urls) && item.photo_urls[2]?.url ? item.photo_urls[2].url : "",
            "photo_3": Array.isArray(item.photo_urls) && item.photo_urls[3]?.url ? item.photo_urls[3].url : "",
            "status": item.status,
            "phone": item.contact_phone,
            "visit_arizona_account_page_url": `https://www.visitarizona.com/${item.slug}`,
            // TODO: Add staging preview link
            "working_hours": item.working_hours,
            "xano_business_listing_id": item.id
        }
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
}