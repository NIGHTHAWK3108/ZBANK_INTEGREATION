CLASS lhc_YCDS_BANK_DATA_INC DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ycds_bank_data_inc RESULT result.

ENDCLASS.

CLASS lhc_YCDS_BANK_DATA_INC IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
