"! @testing BDEF:ZXX_R_TRAVEL_M
CLASS zxx_eml_tests_m DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS tst_determination FOR TESTING RAISING cx_static_check.
    METHODS tst_save_validation FOR TESTING.
    METHODS tst_update FOR TESTING.

    METHODS setup.
    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    CLASS-DATA: cds_test_environment TYPE REF TO if_cds_test_environment.

ENDCLASS.



CLASS zxx_eml_tests_m IMPLEMENTATION.
  METHOD tst_determination.
  "Test Goal: Test calculate total price determination

   "a. Test Configuration

   "b. Code under test

    DATA cba_booking TYPE TABLE FOR CREATE zxx_r_travel_m\_booking.
    cba_booking = VALUE #( ( %cid_ref = 'CID_1'
                             %target = VALUE #( ( %cid = 'CID_B_1'
                                                  booking_id = 1
                                                  booking_status = 'B'
                                                  flight_price = 100
                                                  %control-booking_id = if_abap_behv=>mk-on
                                                  %control-booking_status = if_abap_behv=>mk-on
                                                  %control-flight_price = if_abap_behv=>mk-on  ) ) ) ).

    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
     ENTITY Travel
      CREATE FIELDS (  CustomerId Description BookingFee EndDate BeginDate )
        WITH VALUE #( ( %cid = 'CID_1'  EndDate = sy-datum BeginDate = sy-datum + 10 CustomerId = 100 BookingFee = 20 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
      CREATE BY
        \_booking FROM cba_booking
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

   "c. Asserts
  "1. Assert on the responses of MODIFY EML
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( mapped-travel ) ).
    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( mapped-booking ) ).
    cl_abap_unit_assert=>assert_initial( act = failed ).

    cl_abap_unit_assert=>assert_equals( exp = 'CID_1' act =  mapped-travel[ 1 ]-%cid ).
    cl_abap_unit_assert=>assert_equals( exp = 'CID_B_1' act =  mapped-booking[ 1 ]-%cid ).

  "2. Read the created instance via READ EML and then Assert Result of READ EML

    READ ENTITIES OF zxx_r_travel_m
      ENTITY Travel
        ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
        RESULT DATA(result_travel)
        FAILED DATA(failed_read).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( result_travel ) ).
    cl_abap_unit_assert=>assert_equals( exp = 120 act = result_travel[ 1 ]-totalprice ).

  "3. Read the created instance from CDS and then Assert on the retrieved instance

*  DATA(travel_id) = mapped-travel[ 1 ]-TravelId.
*  Select SINGLE * FROM zxx_r_travel_m INTO @DATA(instance) WHERE travelid = @travel_Id.
*   cl_abap_unit_assert=>assert_equals( exp = 120 act = instance-totalprice ).

  ENDMETHOD.

  METHOD tst_save_validation.
  "Test Goal: Test validation for dates and save sequence

   "a. Test Configuration

    MODIFY ENTITIES OF ZXX_R_TRAVEL_M
     ENTITY Travel
      CREATE FIELDS (  CustomerId Description BookingFee EndDate BeginDate )
        WITH VALUE #( ( %cid = 'CID_1'  EndDate = sy-datum + 10 BeginDate = sy-datum  CustomerId = 100 BookingFee = 20 Description = 'TRAVEL 10' OverallStatus = 'O' ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

   "b. Code under test

  COMMIT ENTITIES
  RESPONSE OF zxx_r_travel_m
    FAILED DATA(failed_commit)
    REPORTED DATA(reported_commit).



   "c. Asserts
  "1. Assert on the responses of COMMIT EML
    cl_abap_unit_assert=>assert_initial( act = failed_commit ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act =  sy-subrc ).

  "2. Read the created instance via READ EML and then Assert Result of READ EML

    READ ENTITIES OF zxx_r_travel_m
      ENTITY Travel
        ALL FIELDS WITH VALUE #( ( %key-TravelId = mapped-travel[ 1 ]-TravelId ) )
        RESULT DATA(result_travel)
        FAILED DATA(failed_read).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( result_travel ) ).
    cl_abap_unit_assert=>assert_equals( exp = sy-datum act = result_travel[ 1 ]-BeginDate ).

  "3. Read the created instance from CDS and then Assert on the retrieved instance

  DATA(travel_id) = mapped-travel[ 1 ]-TravelId.
  Select SINGLE * FROM zxx_r_travel_m INTO @DATA(instance) WHERE travelid = @travel_Id.
  cl_abap_unit_assert=>assert_equals( exp = sy-datum act = instance-BeginDate ).

  ENDMETHOD.

  METHOD class_setup.
    cds_test_environment = cl_cds_test_environment=>create_for_multiple_cds(
                               VALUE #(
                                    ( i_for_entity = 'zxx_r_travel_m' )
                                    ( i_for_entity = 'zxx_r_booking_m' )
                                    )
                                    ).

  ENDMETHOD.

  METHOD class_teardown.
    cds_test_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    cds_test_environment->clear_doubles(  ).
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD tst_update.
  "a. Test Configuration
  DATA test_data TYPE STANDARD TABLE OF zxx_travel_m.
  test_data = VALUE #( ( travel_id = 100 description = 'Travel 100' ) ).

  cds_test_environment->insert_test_data(
    EXPORTING
      i_data             = test_data  ).

  "b. Code under test
  "Execute via EML statements

     MODIFY ENTITIES OF zxx_r_travel_m
      ENTITY Travel
       UPDATE FIELDS (  description )
        WITH VALUE #( ( travelid = 100 description = 'Updated Travel' ) )
       MAPPED DATA(mapped_update)
       FAILED DATA(failed_update).

  "c. Asserts
  "1. Assert on the responses of UPDATE EML statement
    cl_abap_unit_assert=>assert_initial( act = failed_update ).

  "2. Read the created instance via READ EML and then Assert Result of READ EML

    READ ENTITIES OF zxx_r_travel_m
      ENTITY Travel
        ALL FIELDS WITH VALUE #( ( travelid = 100 ) )
      RESULT DATA(travel_result).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( travel_result ) ).
    cl_abap_unit_assert=>assert_equals( exp = 'Updated Travel' act = travel_result[ 1 ]-description ).

  ENDMETHOD.

ENDCLASS.
