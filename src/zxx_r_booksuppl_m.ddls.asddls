@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS data model - Booking Suppl'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZXX_R_BOOKSUPPL_M as select from zxx_book_supp_m
association to parent ZXX_R_BOOKING_M as _Booking on $projection.travel_id = _Booking.travel_id and
                                                     $projection.booking_id = _Booking.booking_id
association[1..1] to ZXX_R_TRAVEL_M as _Travel on $projection.travel_id = _Travel.TravelId 
                                                       
{
  key travel_id,
  key booking_id,
  key booksupp_id,
supplement_id,
@Semantics.amount.currencyCode: 'currency_code'
price,
currency_code,
//local ETag field --> OData ETag
@Semantics.systemDateTime.localInstanceLastChangedAt: true
last_changed_at,
  _Booking,
  _Travel
}
