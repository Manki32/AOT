table events_raw_data {
  auth = false

  schema {
    int id
    timestamp? postDate?
    timestamp? startDate?
    timestamp? endDate?
    bool endDateIsPast?
    int allDay?
    text rrule?
    text freq?
    text interval?
    text count?
    text until?
    text repeatEndDateIsPast?
    bool pushToSite?
    text untilLocalized?
    text byMonth?
    text byYearDay?
    text byMonthDay?
    text byDay?
    text score?
    text tempId?
    text draftId?
    text revisionId?
    text isProvisionalDraft?
    text title?
    text slug?
    text uri?
    timestamp? dateCreated?
    timestamp? dateUpdated?
    text dateLastMerged?
    text url?
    text bodyContent?
    text locationName?
    text address?
    text latitude?
    text longitude?
    text partnerHours?
    text eventAdmission?
    text eventCategories?
    text relatedPartners?
    text partnerRegions?
    text contactEmail?
    text contactPhone?
    text facebookUrl?
    text twitterUrl?
    text websiteUrl?
    text eventTicketUrl?
    text partnerYoutubeVideoUrl?
    text contactFirstNameInternal?
    text contactLastNameInternal?
    text contactPhoneInternal?
    text contactEmailInternal?
    text crmImages?
  }

  index = [{type: "primary", field: [{name: "id"}]}]
}