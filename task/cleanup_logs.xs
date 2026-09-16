// Schedule to run daily (every 86400 seconds)
// Deletes logs rows older than 30 days
task cleanup_logs {
  stack {
    // Calculate the threshold date (30 days ago)
    var $threshold {
      value = now|transform_timestamp:"-30 days"
    }
  
    // Delete records older than the threshold
    db.bulk.delete logs {
      where = $db.logs.created_at < $threshold
    } as $deleted_count
  }

  schedule = [{starts_on: 2025-01-01 00:00:00+0000, freq: 86400}]
}