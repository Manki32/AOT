table s3_images {
  auth = false

  schema {
    int id
    text title?
    text alt?
    text url_clean?
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}