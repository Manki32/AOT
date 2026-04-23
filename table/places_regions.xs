table places_regions {
  auth = false

  schema {
    int id
    text Name?
    text Slug?
    text Item_ID?
    text Sub_header?
    text Sub_header_single_word?
    text Sub_header_block_background_colour?
    text Sub_header_text_colour?
    text Regional_weather_title?
    text Regional_weather_description?
    text Meta_title?
    text Meta_description?
    text Weather_Widget_Code?
    text Hero_background_image?
    text Collection_ID?
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}