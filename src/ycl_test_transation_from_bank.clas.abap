CLASS ycl_test_transation_from_bank DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun .
  class-methods: read_data
  RETURNING VALUE(val)   TYPE string.
   claSS-DATA : transactionid TYPE string,
         code          TYPE string,
         status        TYPE string.

  TYPES:BEGIN OF ty_json,
            transactionid     TYPE string,
            remittername      TYPE string,
            fromaccountnumber TYPE string,
            frombankname      TYPE string,
            utr               TYPE string,
            chequeno          TYPE string,
            narration         TYPE string,
            virtualaccount    TYPE string,
            amount            TYPE string,
            mmid              TYPE string,
            transfermode      TYPE string,
            creditdatetime    TYPE string,
          END OF ty_json.

   claSS-DATA: item_text(5) TYPE c.
   claSS-DATA: it_json TYPE TABLE OF ty_json.

   claSS-DATA : BEGIN OF RESPONSE_1 ,
          transactionid TYPE STRING ,
          cODE TYPE n ,
          STATUS TYPE STRING ,
          end of RESPONSE_1 .



   claSS-DATA  : it_pay TYPE TABLE OF   zbank_data1,
           wa_pay LIKE LINE OF it_pay.

    claSS-DATA : createdate         TYPE datum.
    claSS-DATA : year               TYPE string.
    claSS-DATA : month              TYPE string.
    claSS-DATA : day                TYPE string.
    claSS-DATA : comp_code(4)       TYPE c.
    claSS-DATA : glaccount(10)      TYPE c.
    claSS-DATA : businessplace(4)   TYPE c.

*    claSS-DATA: lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
*               wa_je_deep LIKE LINE OF lt_je_deep.

*    claSS-DATA: ar_item LIKE wa_je_deep-%param-_aritems[],
*          gl_item LIKE wa_je_deep-%param-_glitems[].

    CLASS-DATA:
      lv_cid     TYPE abp_behv_cid,
      i_responce TYPE TABLE OF string.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS YCL_TEST_TRANSATION_FROM_BANK IMPLEMENTATION.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.
   data(body) = me->read_data(  ).
  ENDMETHOD.


 method read_data.

    DATA body type string.


*     wa_pay-transactionid    =  ''.
*     wa_pay-remittername     =  ''.
*     wa_pay-fromaccountnumber=  ''.
*     wa_pay-frombankname     =  ''.
*     wa_pay-utr              =  ''.
*     wa_pay-chequeno         =  ''.
*     wa_pay-narration        =  ''.
*     wa_pay-virtualaccount   =  ''.
*     wa_pay-amount           =  ''.
*     wa_pay-mmid             =  ''.
*     wa_pay-transfermode     =  ''.
*     wa_pay-creditdatetime   =  ''.


    xco_cp_json=>data->from_string( body )->write_to( REF #( wa_pay ) ).

    TRY.
        lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
    TYPES:BEGIN OF ty_generic ,
            errorcode         TYPE string,
            errormessage      TYPE string,
            domainreferenceno TYPE string,
          END OF ty_generic.
    DATA:generic TYPE ty_generic.
    TYPES:BEGIN OF ty_res,
            genericcorporatealertresponse LIKE  generic,
          END OF ty_res.
    DATA:res TYPE ty_res.
*    MOVE-CORRESPONDING wa_pay TO it_pay.
    READ TABLE it_pay INTO wa_pay INDEX 1.
    SPLIT wa_pay-creditdatetime  AT '-'  INTO year month day.
    REPLACE ALL OCCURRENCES OF 'VL' IN wa_pay-virtualaccount WITH ''.
    CONDENSE wa_pay-virtualaccount.
    wa_pay-creditdate = wa_pay-creditdatetime+0(10).
    CONCATENATE  year month day INTO createdate.
      SELECT SINGLE businesspartner
                   FROM
                     i_businesspartnerbank
                   WITH PRIVILEGED ACCESS WHERE  bankaccount = @wa_pay-virtualaccount
      INTO @DATA(businesspartner).

*    SELECT SINGLE * FROM i_journalentrytp WITH PRIVILEGED ACCESS WHERE accountingdocumentheadertext = @wa_pay-transactionid  AND documentdate = @createdate INTO @DATA(it_alredy).
     SELECT SINGLE * FROM
                     zbank_data1 WITH PRIVILEGED ACCESS
                      WHERE transactionid = @wa_pay-transactionid
                      and fromaccountnumber = @wa_pay-fromaccountnumber
                      and frombankname = @wa_pay-frombankname
                      and remittername = @wa_pay-remittername
                      and utr  = @wa_pay-utr
                                 INTO @DATA(it_alredy).
 if it_alredy is INITIAL .
 MODIFY zbank_data1 FROM  @wa_pay .
 if sy-subrc is INITIAL .
 COMMIT WORK .
 ENDIF.

 ENDIF.
if sy-subrc = 0 and it_alredy is not INITIAL .
RESPONSE_1-code         = 1.
RESPONSE_1-status       = 'Error - Trasaction Entry Already Processed '.
RESPONSE_1-transactionid   = wa_pay-transactionid.


else .
if businesspartner is NOT INITIAL .
  MODIFY zbank_data1 FROM  @wa_pay .
  if sy-subrc is INITIAL .
 COMMIT WORK .
 ENDIF.

RESPONSE_1-code         = 0.
RESPONSE_1-status       = 'Success'.
RESPONSE_1-transactionid   = wa_pay-transactionid.

else .
RESPONSE_1-code         = 1.
RESPONSE_1-status       = 'Error - Invalid Virtual Account No'.
RESPONSE_1-transactionid   = wa_pay-transactionid.

endif .

endif .

     DATA:doc      TYPE string,
         error    TYPE string,
         responce TYPE string.
     DATA:json TYPE REF TO if_xco_cp_json_data.
    CLEAR:responce.

      xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = RESPONSE_1 "i_responce
      RECEIVING
        ro_json_data = json ).
    json->to_string(
      RECEIVING
        rv_string = responce ).

*    REPLACE ALL OCCURRENCES OF 'GENERICCORPORATEALERTRESPONSE'  IN responce WITH 'GenericCorporateAlertResponse'.
*    REPLACE ALL OCCURRENCES OF 'ERRORCODE'  IN responce WITH 'errorCode'.
*    REPLACE ALL OCCURRENCES OF 'ERRORMESSAGE'  IN responce WITH 'errorMessage'.
*    REPLACE ALL OCCURRENCES OF 'DOMAINREFERENCENO'  IN responce WITH 'domainReferenceNo'.
*    response->set_text( responce ).



  endmethod.
ENDCLASS.
