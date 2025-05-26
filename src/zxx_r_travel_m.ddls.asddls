@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS data model - travel'
define root view entity ZXX_R_TRAVEL_M as select from zxx_travel_m
composition[0..*] of ZXX_R_BOOKING_M as _BOOKING
{
  key travel_id as TravelId,
  agency_id as AgencyId,
  customer_id as CustomerId,
  begin_date as BeginDate,
  end_date as EndDate,
  booking_fee as BookingFee,
  total_price as TotalPrice,
  currency_code as CurrencyCode,
  description as Description,
  overall_status as OverallStatus,
  created_by as CreatedBy,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true  
  last_changed_at as LastChangedAt,
  _BOOKING
}
