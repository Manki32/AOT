// Edit user details record
query "user_details/{user_details_id}" verb=PATCH {
  api_group = "Authentication"
  auth = "user"

  input {
    int user_details_id? filters=min:1
    dblink {
      table = "user_detail"
      override = {
        user_id          : {hidden: true}
        profile_image    : {hidden: true}
        hubspot_record_id: {hidden: true}
      }
    }
  
    file? profile_image_file?
  }

  stack {
    var $image {
      value = ``
    }
  
    db.get user_detail {
      field_name = "id"
      field_value = $input.user_details_id
    } as $get_details
  
    precondition ($auth.id == $get_details.user_id) {
      error_type = "unauthorized"
      error = "Unauthorized: You're not allowed to edit this record"
      payload = "Unauthorized: You're not allowed to edit this record"
    }
  
    conditional {
      if ($input.profile_image_file) {
        storage.create_image {
          value = $input.profile_image_file
          access = "public"
          filename = ""
        } as $new_profile_image
      
        var.update $image {
          value = $new_profile_image
        }
      }
    }
  
    db.patch user_detail {
      field_name = "id"
      field_value = $input.user_details_id
      data = {}
        |set_ifnotempty:"id":($input.user_details_id
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"address":($input.address
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"session_id":($input.session_id
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"interests":($input.interests
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"email_preferences":($input.email_preferences
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"onboarding_complete":($input.onboarding_complete
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"activities":($input.activities
          |filter_null:""
          |filter_empty_text:""
        )
        |set_ifnotempty:"profile_image":(""
          |set_ifnotempty:"":$image
          |filter_empty_text:""
          |filter_null:""
        )
    } as $user_details
  }

  response = $user_details
}