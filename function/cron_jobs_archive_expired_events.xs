function "cron_jobs/Archive expired events" {
  input {
  }

  stack {
    db.query event {
      where = $db.event.end_date < now && ($db.event.status == "Approved" || ($db.event.status == "Requesting approval" && $db.event.wf_id != "")) && $db.event.hs_id != ""
      return = {type: "list"}
    } as $event1
  
    var $items_archived {
      value = []
    }
  
    conditional {
      if (($event1|count) > 0) {
        foreach ($event1) {
          each as $item {
            function.run "HubSpot/Hubspot -> Update Object" {
              input = {
                properties : {}|set:"status":"Archived"
                object_type: "2-39972221"
                object_id  : $item.hs_id
              }
            } as $hs_result
          
            array.push $items_archived {
              value = $hs_result
            }
          }
        }
      }
    }
  }

  response = {result1: $event1, func: $items_archived}
}