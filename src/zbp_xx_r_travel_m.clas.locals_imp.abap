CLASS ltcl_managed DEFINITION DEFERRED FOR TESTING.
CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltcl_managed.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.
    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION travel~deductdiscount RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.

      AUTHORITY-CHECK OBJECT 'S_DEVELOP'
        ID 'ACTVT' FIELD '01'
        ID 'OBJTYPE' FIELD 'CLAS'.


      IF sy-subrc = 0.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD calculateTotalPrice.
    "Total Price = Booking Fee (Travel) + Flight Price (Booking) + Supplement Price (Booking Supplement)

   READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
    ENTITY Travel
      FIELDS ( BookingFee )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      BY \_booking
      FIELDS ( flight_price )
      WITH CORRESPONDING #( keys )
      RESULT DATA(bookings).


    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-TotalPrice += <travel>-BookingFee.

      LOOP AT bookings INTO DATA(booking) WHERE travel_id = <travel>-TravelId.
        <travel>-TotalPrice += booking-flight_price.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES of zxx_r_travel_m IN LOCAL MODE
    ENTITY Travel
      UPDATE FIELDS ( totalprice )
        WITH CORRESPONDING #( travels )
    FAILED DATA(failed)  .

  ENDMETHOD.

  METHOD validateDates.
  "BEGIN DATE < ENDDATE

   READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
    ENTITY Travel
      FIELDS ( EndDate BeginDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-BeginDate > travel-EndDate.
         APPEND VALUE #( %tky = travel-%tky ) TO failed-travel. "

         APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages(
                                   textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = travel-begindate
                                   end_date   = travel-enddate
                                   travel_id  = travel-travelid )

                         %tky = travel-%tky

                         %element-begindate = if_abap_behv=>mk-on
                         %element-enddate = if_abap_behv=>mk-on

                                  )  TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES oF zxx_r_travel_m IN LOCAL MODE
      ENTITY Travel
        UPDATE FROM VALUE #( FOR key IN keys ( %key = key-%key OverallStatus = 'A' %control-OverallStatus = if_abap_behv=>mk-on ) ).

    READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                              %param = travel ) ).
  ENDMETHOD.

  METHOD deductDiscount.

    READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
      ENTITY Travel
        FIELDS ( TotalPrice )
          WITH CORRESPONDING #( keys )
        RESULT DATA(travels).


    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      <travel>-TotalPrice -= <travel>-TotalPrice * keys[ %key-TravelId = <travel>-TravelId ]-%param-discount_percent / 100.
    ENDLOOP.

    MODIFY ENTITIES of zxx_r_travel_m IN LOCAL MODE
    ENTITY Travel
      UPDATE FIELDS ( totalprice )
        WITH CORRESPONDING #( travels )
    FAILED DATA(failed_update)  .

    READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(updated_travels).

    result = VALUE #( FOR travel IN updated_travels ( %tky = travel-%tky
                                                      %param = travel ) ).
  ENDMETHOD.

  METHOD earlynumbering_create.

    LOOP at entities INTO DATA(entity).

      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '1'
              object            = 'ZXX_NR_T_M'
              quantity          = 1
            IMPORTING
              number            = data(travel_id)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
          ).
        CATCH cx_number_ranges.
          "handle exception
          EXIT.
      ENDTRY.

      entity-TravelId = travel_id.

      APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO mapped-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

      READ ENTITIES OF zxx_r_travel_m IN LOCAL MODE
      ENTITY Travel
        ALL FIELDS WITH
          CORRESPONDING #( keys )
        RESULT DATA(travels).

      LOOP AT travels INTO DATA(travel).

        IF travel-OverallStatus = 'A'.
          APPEND VALUE #( %key = travel-TravelId %features-%action-acceptTravel = if_abap_behv=>fc-o-disabled   ) TO result.
        ELSE.
          APPEND VALUE #( %key = travel-TravelId %features-%action-acceptTravel = if_abap_behv=>fc-o-enabled   ) TO result.
        ENDIF.

      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
