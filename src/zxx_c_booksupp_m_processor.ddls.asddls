@EndUserText.label: 'Booking supplement processor projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZXX_C_BOOKSupp_M_PROCESSOR as projection on ZXX_R_BOOKSUPPL_M
{
  key travel_id,
  key booking_id,
  key booksupp_id,
  supplement_id,
  price,
  currency_code,
  last_changed_at,
  /* Associations */
  _Booking:  redirected to parent ZXX_C_BOOKING_M_PROCESSOR,
  _Travel: redirected to ZXX_C_TRAVEL_M_PROCESSOR
}
