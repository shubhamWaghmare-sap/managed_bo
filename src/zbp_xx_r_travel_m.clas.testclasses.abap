*"* use this source file for your ABAP unit test classes
class ltcl_managed definition final for testing
  duration short
  risk level harmless.

  private section.
    methods:
      test_determination for testing raising cx_static_check.

    methods:
      test_validation for testing raising cx_static_check.

    METHODS setup.
    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    CLASS-DATA: cds_test_environment TYPE REF TO if_cds_test_environment.
    CLASS-DATA: cut TYPE REF TO lhc_Travel.
endclass.


class ltcl_managed implementation.

  METHOD class_setup.
    cds_test_environment = cl_cds_test_environment=>create_for_multiple_cds(
                               VALUE #(
                                    ( i_for_entity = 'zxx_r_travel_m' )
                                    ( i_for_entity = 'zxx_r_booking_m' )
                                    )
                                    ).

    CREATE OBJECT cut FOR TESTING.
  ENDMETHOD.

  METHOD class_teardown.
    cds_test_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    cds_test_environment->clear_doubles(  ).
    ROLLBACK ENTITIES.
  ENDMETHOD.

  method test_determination.
  "Test Goal: Test calculate total price determination

   "a. Test Configuration
  DATA test_travel TYPE STANDARD TABLE OF zXX_travel_m.
  test_travel = VALUE #( ( travel_id = 1 description = 'Travel 1' booking_fee = 20 ) ).

  DATA test_booking TYPE STANDARD TABLE OF zXX_booking_m.
  test_booking = VALUE #( ( travel_id = 1  booking_id = 1 flight_price = 10 ) ).

  cds_test_environment->insert_test_data(
    EXPORTING
      i_data             = test_travel  ).

  cds_test_environment->insert_test_data(
    EXPORTING
      i_data             = test_booking  ).



   "b. Code under test

    DATA reported TYPE RESPONSE FOR REPORTED LATE zxx_r_travel_m.

    cut->calculatetotalprice(
      EXPORTING
        keys     = VALUE #( (  TravelId = 1 ) )
      CHANGING
        reported = reported
    ).

   "c. Asserts
  "1. Assert on the responses of method
    cl_abap_unit_assert=>assert_initial( act = reported ).

  "2. Read the created instance via READ EML and then Assert Result of READ EML

    READ ENTITIES OF zxx_r_travel_m
      ENTITY Travel
        ALL FIELDS WITH VALUE #( ( %key-TravelId = 1 ) )
        RESULT DATA(result_travel)
        FAILED DATA(failed_read).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = lines( result_travel ) ).
    cl_abap_unit_assert=>assert_equals( exp = 30 act = result_travel[ 1 ]-totalprice ).

  "3. Read the created instance from CDS and then Assert on the retrieved instance

*  DATA(travel_id) = mapped-travel[ 1 ]-TravelId.
*  Select SINGLE * FROM zxx_r_travel_m INTO @DATA(instance) WHERE travelid = @travel_Id.
*   cl_abap_unit_assert=>assert_equals( exp = 120 act = instance-totalprice ).
  endmethod.

  method test_validation.

  "Test Goal: Test dates validation, where validation fails

  "a. Test Configuration
  "Insert test data using CDS TDF

  DATA test_travel TYPE STANDARD TABLE OF zxx_travel_m.
  test_travel = VALUE #( ( travel_id = 1 description = 'Travel 1' booking_fee = 20
                            begin_date = cl_abap_context_info=>get_system_date( ) + 10
                            end_date   = cl_abap_context_info=>get_system_date( ) ) ).

  cds_test_environment->insert_test_data(
    EXPORTING
      i_data             = test_travel  ).

  "b. Code under test
  "Execute method
  DATA cut TYPE REF TO lhc_Travel.
  CREATE OBJECT cut FOR TESTING.

  DATA reported TYPE RESPONSE FOR REPORTED LATE ZXX_R_TRAVEL_M.
  DATA failed TYPE RESPONSE FOR FAILED LATE ZXX_R_TRAVEL_M.

  cut->validatedates(
    EXPORTING
      keys     =  VALUE #( (  TravelId = 1 ) )
    CHANGING
      failed   = failed
      reported = reported
  ).

  "c. Asserts
  "1. Assert on the reported responses
    cl_abap_unit_assert=>assert_not_initial( act = failed ).
    cl_abap_unit_assert=>assert_not_initial( act = reported ).

    cl_abap_unit_assert=>assert_equals( exp = 1 act = failed-travel[ 1 ]-travelid ).


"    DATA msg TYPE REF TO /dmo/cm_flight_messages.
    DATA(msg) = NEW /dmo/cm_flight_messages(
                                   textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = test_travel[ 1 ]-begin_date
                                   end_date   = test_travel[ 1 ]-end_date
                                   travel_id  = test_travel[ 1 ]-travel_id ).

    cl_abap_unit_assert=>assert_equals( exp = msg->get_text( ) act = reported-travel[ 1 ]-%msg->if_message~get_text( ) ).

  endmethod.

endclass.
