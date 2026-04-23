table marketplace_countries {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    image? flag_icon?
    text region? filters=trim
    text language? filters=trim
    text code? filters=trim|lower
    text product_price_notation filters=trim
    bool push_to_wf_cms?=true
    text wf_slug? filters=trim
    text wf_item_id? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]

  tags = ["exploration"]
}