addon s3_images {
  input {
    int s3_images_id? {
      table = "s3_images"
    }
  }

  stack {
    db.query s3_images {
      where = $db.s3_images.id == $input.s3_images_id
      return = {type: "single"}
    }
  }
}