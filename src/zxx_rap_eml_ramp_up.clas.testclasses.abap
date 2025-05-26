*"* use this source file for your ABAP unit test classes
class ltcl_ramp_up_on_EML definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      managed for testing raising cx_static_check,
      test_deep_create for testing raising cx_static_check,
      test_rollback for testing raising cx_static_check,
      test_act_acceptTravel for testing raising cx_static_check.
endclass.


class ltcl_ramp_up_on_EML implementation.

  method managed.
  "MODIFY

  DATA create_instances TYPE TABLE FOR CREATE zxx_r_travel_m\\Travel.

* With external numbering
*  MODIFY ENTITIES OF ZXX_R_TRAVEL_M
*    ENTITY Travel
*      CREATE FIELDS ( TravelId CustomerId Description )
*        WITH VALUE #( ( %cid = 'CID_1' %key-TravelId = 3 CustomerId = 100 Description = 'TRAVEL 1' OverallStatus = 'O' ) )
*        MAPPED DATA(mapped)
*        FAILED DATA(failed)
*        REPORTED DATA(reported).

" With Early Internal Numbering
  MODIFY ENTITIES OF ZXX_R_TRAVEL_M
    ENTITY Travel
      CREATE FIELDS ( CustomerId Description )
        WITH VALUE #( ( %cid = 'CID_1' CustomerId = 100 Description = 'TRAVEL 1' OverallStatus = 'O' ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

"  COMMIT ENTITIES.

  DATA read_instances TYPE TABLE FOR READ IMPORT zxx_r_travel_m\\Travel.

  read_instances = value #( ( TravelId = 1 ) ( TravelId = 2 ) ( TravelId = 3 ) ( TravelId = 4 ) ).

  READ ENTITIES OF zxx_r_travel_m
    ENTITY Travel
      ALL FIELDS WITH read_instances
      RESULT DATA(result)
      FAILED DATA(failed_read).

  endmethod.

  method test_deep_create.

    DATA cba_booking TYPE TABLE FOR CREATE zxx_r_travel_m\_booking.
    cba_booking = VALUE #( ( %cid_ref = 'CID_1'
                             %target = VALUE #( ( %cid = 'CID_B_1'
                                                  booking_id = 1
                                                  booking_status = 'B'
                                                  flight_price = 100
                                                  %control-booking_id = if_abap_behv=>mk-on
                                                  %control-booking_status = if_abap_behv=>mk-on
                                                  %control-flight_price = if_abap_behv=>mk-on  ) ) ) ).

* With external numbering
*    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
*     ENTITY Travel
*      CREATE FIELDS ( TravelId CustomerId Description BookingFee EndDate BeginDate )
*        WITH VALUE #( ( %cid = 'CID_1' %key-TravelId = 11  EndDate = sy-datum BeginDate = sy-datum + 10 CustomerId = 100 BookingFee = 20 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
*      CREATE BY
*        \_booking FROM cba_booking
*        MAPPED DATA(mapped)
*        FAILED DATA(failed)
*        REPORTED DATA(reported).

" With Early Internal Numbering
    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
     ENTITY Travel
      CREATE FIELDS (  CustomerId Description BookingFee EndDate BeginDate )
        WITH VALUE #( ( %cid = 'CID_1'  EndDate = sy-datum BeginDate = sy-datum + 10 CustomerId = 100 BookingFee = 20 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
      CREATE BY
        \_booking FROM cba_booking
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

  COMMIT ENTITIES
  RESPONSE OF zxx_r_travel_m
    FAILED DATA(failed_commit)
    REPORTED DATA(reported_commit).

  SELECT SINGLE * FROM zxx_travel_m WHERE travel_id = 11 INTO @DATA(travel_11).

  READ ENTITIES OF zxx_r_travel_m
    ENTITY Travel
      ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
      RESULT DATA(result_travel)
      BY \_booking ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
      RESULT DATA(result_booking)
      FAILED DATA(failed_read).

  endmethod.

  method test_rollback.
    DATA cba_booking TYPE TABLE FOR CREATE zxx_r_travel_m\_booking.
    cba_booking = VALUE #( ( %cid_ref = 'CID_1'
                             %target = VALUE #( ( %cid = 'CID_B_1'
                                                  booking_id = 1
                                                  booking_status = 'B'
                                                  flight_price = 10
                                                  %control-booking_id = if_abap_behv=>mk-on
                                                  %control-booking_status = if_abap_behv=>mk-on  ) ) ) ).

* With external numbering
*    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
*     ENTITY Travel
*      CREATE FIELDS ( TravelId CustomerId Description )
*        WITH VALUE #( ( %cid = 'CID_1' %key-TravelId = 10 CustomerId = 100 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
*      CREATE BY
*        \_booking FROM cba_booking
*        MAPPED DATA(mapped)
*        FAILED DATA(failed)
*        REPORTED DATA(reported).

" With Early Internal Numbering
    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
     ENTITY Travel
      CREATE FIELDS ( CustomerId Description )
        WITH VALUE #( ( %cid = 'CID_1' CustomerId = 100 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
      CREATE BY
        \_booking FROM cba_booking
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

  ROLLBACK ENTITIES.

  READ ENTITIES OF zxx_r_travel_m
    ENTITY Travel
      ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
      RESULT DATA(result_travel)
      BY \_booking ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
      RESULT DATA(result_booking)
      FAILED DATA(failed_read).

  endmethod.

  method test_act_accepttravel.

    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
      ENTITY Travel
        EXECUTE acceptTravel
        FROM VALUE #( ( %key-TravelId = '2'  ) )
        RESULT DATA(result).

  endmethod.

endclass.
