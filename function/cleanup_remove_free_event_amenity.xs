// One-off cleanup: removes the "Free Event" amenity (id 749817) from every
// business_listing that currently has it. Leaves all other amenities intact.
// Safe to re-run: if no listings match, it just returns an empty result set.
function "cleanup/remove_free_event_amenity" {
  input {
  }

  stack {
    // Hardcoded id of the "Free Event" amenity. This is a one-off cleanup,
    // so we skip the lookup and any null-handling that comes with it.
    var $free_event_id {
      value = 749817
    }
  
    // Find every business_listing whose amenities array contains the target id.
    // `amenities` is an integer[], so we use `overlaps` with a single-element
    // array — this matches any listing whose amenities intersect [749817].
    db.query business_listing {
      where = 749817 in $db.business_listing.amenities
      return = {type: "list"}
    } as $affected_listings
  
    // Track ids we updated so the response is auditable.
    var $updated_ids {
      value = []
    }
  
    // Walk each affected listing and rewrite its amenities array with the
    // "Free Event" id filtered out. `diff` returns the left array minus any
    // values in the right array — perfect for a targeted removal.
    foreach ($affected_listings) {
      each as $listing {
        var $new_amenities {
          value = $listing.amenities|diff:[$free_event_id]
        }
      
        db.edit business_listing {
          field_name = "id"
          field_value = $listing.id
          data = {amenities: $new_amenities}
        } as $updated_listing
      
        array.push $updated_ids {
          value = $listing.id
        }
      }
    }
  }

  response = {
    status               : "done"
    free_event_amenity_id: $free_event_id
    updated              : $updated_ids|count
    updated_ids          : $updated_ids
    !AFFECT              : $affected_listings
  }
}