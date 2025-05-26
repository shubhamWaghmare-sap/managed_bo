@EndUserText.label: 'Booking processor projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: {
  headerInfo: { typeName: 'Booking',
                typeNamePlural: 'Bookings',
                title: { type: #STANDARD, value: 'Booking_ID' } } }
define view entity ZXX_C_BOOKING_M_PROCESSOR as projection on ZXX_R_BOOKING_M
{
      @UI.facet: [ { id:            'Booking',
                     purpose:       #STANDARD,
                     type:          #IDENTIFICATION_REFERENCE,
                     label:         'Booking',
                     position:      10 },
                   { id:            'BookingSupplement',
                     purpose:       #STANDARD,
                     type:          #LINEITEM_REFERENCE,
                     label:         'Booking Supplement',
                     position:      20,
                     targetElement: '_BookSupplement'} ]

      @Search.defaultSearchElement: true
  key travel_id,
      @UI: { lineItem:       [ { position: 20, importance: #HIGH } ],
             identification: [ { position: 20 } ] }
      @Search.defaultSearchElement: true
  key booking_id,
  
      @UI: { lineItem:       [ { position: 30, importance: #HIGH } ],
             identification: [ { position: 30 } ] }
  booking_date,
  
      @UI: { lineItem:       [ { position: 40, importance: #HIGH } ],
             identification: [ { position: 40 } ] }
  customer_id,
  
      @UI: { lineItem:       [ { position: 50, importance: #HIGH } ],
             identification: [ { position: 50 } ] }
  carrier_id,
      @UI: { lineItem:       [ { position: 60, importance: #HIGH } ],
             identification: [ { position: 60 } ] }
  connection_id,
      @UI: { lineItem:       [ { position: 70, importance: #HIGH } ],
             identification: [ { position: 70 } ] }
  flight_date,
      @UI: { lineItem:       [ { position: 80, importance: #HIGH } ],
             identification: [ { position: 80 } ] }
      @Semantics.amount.currencyCode: 'Currency_code'
  flight_price,
  currency_code,
      @UI: { lineItem:       [ { position: 90, importance: #HIGH, label: 'Status' } ],
             identification: [ { position: 90, label: 'Status' } ],
             textArrangement: #TEXT_ONLY }
  booking_status,
  
      @UI.hidden: true
  last_changed_at,
  /* Associations */
  _BookSupplement: redirected to composition child ZXX_C_BOOKSupp_M_PROCESSOR,
  _Travel: redirected to parent ZXX_C_TRAVEL_M_PROCESSOR
}
