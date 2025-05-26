@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS data model - Booking'
define view entity ZXX_R_BOOKING_M as select from zxx_booking_m
composition[0..*] of ZXX_R_BOOKSUPPL_M as _BookSupplement
association to parent ZXX_R_TRAVEL_M as _Travel on $projection.travel_id = _Travel.TravelId 
{
  key travel_id,
  key booking_id,
booking_date,
customer_id,
carrier_id,
connection_id,
flight_date,
@Semantics.amount.currencyCode: 'currency_code'
flight_price,
currency_code,
booking_status,
//local ETag field --> OData ETag
@Semantics.systemDateTime.localInstanceLastChangedAt: true
last_changed_at,
  _BookSupplement,
  _Travel
}
