// Test table created via MCP
table test_table {
  auth = false

  schema {
    // Unique identifier
    int id
  
    // Creation timestamp
    timestamp created_at?=now
  
    // Item name
    text name filters=trim
  
    // Favourite color
    text color? filters=trim
  
    // Random score
    int score?
  
    // Whether the record is active
    bool is_active?=true
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}