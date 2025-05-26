@EndUserText.label: 'Travel processor projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI: {
  headerInfo: { typeName: 'Travel', typeNamePlural: 'Travels', title: { type: #STANDARD, value: 'TravelID' } } }
  define root view entity ZXX_C_TRAVEL_M_PROCESSOR
  provider contract transactional_query as projection on ZXX_R_TRAVEL_M
{

      @UI.facet: [ { id:              'Travel',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Travel',
                     position:        10 },
                   { id:              'Booking',
                     purpose:         #STANDARD,
                     type:            #LINEITEM_REFERENCE,
                     label:           'Booking',
                     position:        20,
                     targetElement:   '_BOOKING'}]


  @UI: {
      lineItem:       [ { position: 10, importance: #HIGH } ],
      identification: [ { position: 10, label: 'Travel ID' },
                        { type: #FOR_ACTION, dataAction: 'deductDiscount', label: 'Deduct Discount'} ] }
  key TravelId,
  @UI: {
      lineItem:       [ { position: 20, importance: #HIGH } ],
      identification: [ { position: 20, label: 'AgencyID' } ] }
  AgencyId,
  @UI: {
      lineItem:       [ { position: 30, importance: #HIGH } ],
      identification: [ { position: 30, label: 'Customer ID' } ] }
  CustomerId,
  @UI: {
      lineItem:       [ { position: 40, importance: #HIGH } ],
      identification: [ { position: 40, label: 'Begin Date' } ] }
  BeginDate,
  @UI: {
      lineItem:       [ { position: 50, importance: #HIGH } ],
      identification: [ { position: 50, label: 'End date' } ] }
  EndDate,
  @UI: {
      lineItem:       [ { position: 60, importance: #HIGH } ],
      identification: [ { position: 60, label: 'Booking Fee' } ] }
  BookingFee,
  @UI: {
      lineItem:       [ { position: 70, importance: #HIGH } ],
      identification: [ { position: 70, label: 'Total price' } ] }
  TotalPrice,
  @UI: {
      lineItem:       [ { position: 80, importance: #HIGH } ],
      identification: [ { position: 80, label: 'Currency Code' } ] }
  CurrencyCode,
  @UI: {
      lineItem:       [ { position: 90, importance: #HIGH } ],
      identification: [ { position: 90, label: 'Description' } ] }
  Description,
  @UI: {
      lineItem:       [ { position: 100, importance: #HIGH },
                         { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel'} ],
      identification: [ { position: 100, label: 'Overall Status' },
                        { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel'} ] }
  OverallStatus,

@UI.hidden: true  CreatedBy,
@UI.hidden: true  CreatedAt,
@UI.hidden: true  LastChangedBy,
@UI.hidden: true  LastChangedAt,
  /* Associations */
  _BOOKING:redirected to composition child ZXX_C_BOOKING_M_PROCESSOR
}
