task "Unpublish expired events" {
  stack {
    function.run "cron_jobs/Archive expired events" as $func1
  }

  schedule = [{starts_on: 2025-07-23 07:00:00+0000, freq: 86400}]
}