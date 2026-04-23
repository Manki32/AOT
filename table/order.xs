// Stores customer order and inquiry details, including contact info, travel preferences, and personalization requests.
table order {
  auth = false

  schema {
    int id
    timestamp created_at?=now {
      visibility = "private"
    }
  
    // Reference to the user who placed this order/inquiry.
    int? user_id? {
      table = "user"
    }
  
    // First name of the customer.
    text first_name? filters=trim
  
    // Last name of the customer.
    text last_name? filters=trim
  
    // Primary address of the customer.
    text address? filters=trim
  
    // Secondary address line of the customer.
    text address2? filters=trim
  
    // City of the customer.
    text city? filters=trim
  
    // Zip code of the customer.
    text zip? filters=trim
  
    // State/Province of the customer.
    text state? filters=trim
  
    // Phone number of the customer.
    text phone? filters=trim
  
    // Email address of the customer.
    email email? filters=trim|lower
  
    // Company name associated with the customer.
    text company_name? filters=trim
  
    int[] interests? {
      table = "category"
    }
  
    // Preferred start date for travel.
    date traveling_start_date?
  
    // Preferred end date for travel.
    date traveling_end_date?
  
    // Indicates if personalization is requested.
    bool personalization?
  
    bool synced_to_epi_hab?
    bool synced_to_hubspot?
    text packem_id? filters=trim
  }

  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}