// # Function Documentation: HubSpot → Get Contact
// 
// ## Overview
// This function retrieves a specific contact from HubSpot using the contact's ID. It involves setting environment variables, preparing the request, and handling the response from the HubSpot API.
// 
// ## Inputs
// 1. **id** (integer)
//    - **Description:** The unique identifier of the contact to be retrieved.
// 
// 2. **properties** (text[])
//    - **Description:** A list of contact properties to retrieve.
// 
// ## Function Stack
// ### 1. Environment Variables
// 1. **Create Variable: `reg`**
//    - **Purpose:** Stores the `hubspot_api_key` retrieved from the environment.
// 
// ### 2. HubSpot API Request
// 1. **API Request to `https://api.hubapi.com/crm/v3/objects/contacts/{id}`**
//    - **Purpose:** Sends a GET request to retrieve the specified contact from HubSpot.
// 
// ### 3. Preconditions
// 1. **Precondition: `hubspot_api.response.status == 200`**
//    - **Purpose:** Ensures successful retrieval of the contact with HTTP status code 200.
// 
// ## Response
// - The function returns the result from the HubSpot API response.
// 
// ### Success response
// ```json
// {
//     "id": "12345",
//     "properties": {
//         "company": "HubSpot",
//         "createdate": "2024-09-12T10:58:14.335Z",
//         "hs_object_id": "12345",
//         "lastmodifieddate": "2024-09-12T10:58:18.831Z"
//     },
//     "createdAt": "2024-09-12T10:58:14.335Z",
//     "updatedAt": "2024-09-12T10:58:18.831Z",
//     "archived": false
// }
// ```
// 
// ### Error response
// ```json
// {
//   "message": "Uh oh! Hubspot returned with an error: Authentication credentials not found. This API supports OAuth 2.0 authentication and you can find more details at https://developers.hubspot.com/docs/methods/auth/oauth-overview"
// }
// ```
// 
// ## Example
// ### Input
// ```json
// {
//   "id": 123456,
//   "properties": [
//     "company"
//   ]
// }
// ```
// ### Output
// ```json
// {
//     "id": "123456",
//     "properties": {
//         "company": "UC",
//         "createdate": "2024-09-23T13:30:40.386Z",
//         "hs_object_id": "60968500829",
//         "lastmodifieddate": "2024-09-23T13:31:43.044Z"
//     },
//     "createdAt": "2024-09-23T13:30:40.386Z",
//     "updatedAt": "2024-09-23T13:31:43.044Z",
//     "archived": false
// }
// ```
function "HubSpot/Hubspot -> Get Contact by Email" {
  input {
    text[] properties? filters=trim
    email email filters=trim|lower
    text id? filters=trim
  }

  stack {
    // Hubspot API Request
    group {
      stack {
        api.request {
          url = "https://api.hubapi.com/crm/v3/objects/contacts/"|concat:$input.email:""
          method = "GET"
          params = {}
            |set:"idProperty":"email"
            |set:"limit":"10"
            |set:"archived":"false"
            |set:"properties":($input.properties|join:",")
          headers = []
            |push:("Authorization: Bearer"|concat:$env.hubspot_api:" ")
        } as $hubspot_api
      }
    }
  }

  response = $hubspot_api
}