table tag {
  auth = false

  schema {
    int id
    text name?
    text slug?
    int level?
    int old_crm_id?
    text wf_id? filters=trim
    int category_id? {
      table = "category"
    }
  
    text alt_tag? filters=trim
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}