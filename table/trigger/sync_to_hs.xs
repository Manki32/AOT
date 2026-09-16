table_trigger sync_to_hs {
  table = "order"

  input {
    json new
    json old
    enum action {
      values = ["insert", "update", "delete", "truncate"]
    }
  
    text datasource
  }

  stack {
    // Log the trigger activation
    function.run "core/log_request" {
      input = {
        endpoint   : "Trigger: sync_to_hs"
        method     : "TRIGGER"
        status     : 200
        input_data : $input.new
        output_data: {message: "Trigger started"}
      }
    }
  
    function.run "HubSpot/upsert_hs_contact_after_order" {
      input = {
        email               : $input.new.email
        first_name          : $input.new.first_name
        last_name           : $input.new.last_name
        hs_marketable_status: $input.new.personalization
      }
    } as $func1
  
    db.edit order {
      field_name = "id"
      field_value = $input.new.id
      enforce_hidden_fields = false
      data = {synced_to_hubspot: true}
    } as $order2
  }

  where = $db.NEW.synced_to_epi_hab == true
  actions = {insert: true}
  datasources = ["live"]
}