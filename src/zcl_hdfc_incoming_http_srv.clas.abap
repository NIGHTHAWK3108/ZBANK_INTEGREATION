class ZCL_HDFC_INCOMING_HTTP_SRV definition
  public
  create public .

public section.
INTERFACES if_oo_adt_classrun .
 DATA:transactionid TYPE string,
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
    DATA : item_text(5) TYPE c.
    DATA:it_json TYPE TABLE OF ty_json.
*         { "transactionid": "1400000072","code": "200 ","status": "Success"}
DATA : BEGIN OF RESPONSE_1 ,
      transactionid TYPE STRING ,
      cODE TYPE n ,
      STATUS TYPE STRING ,
      end of RESPONSE_1 .



    DATA :
           it_pay TYPE TABLE OF   zbank_data1,
           wa_pay LIKE LINE OF it_pay.
    DATA : createdate         TYPE datum.
    DATA : year               TYPE string.
    DATA : month              TYPE string.
    DATA : day                TYPE string.
    DATA : comp_code(4)       TYPE c.
    DATA : glaccount(10)      TYPE c.
    DATA : businessplace(4)   TYPE c.

*    DATA : BEGIN OF w_json,
*             genericcorporatealertrequest LIKE it_json,
*           END OF w_json.

    DATA:lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
         wa_je_deep LIKE LINE OF lt_je_deep.

    DATA :ar_item LIKE wa_je_deep-%param-_aritems[],
          gl_item LIKE wa_je_deep-%param-_glitems[].

    CLASS-DATA:
      lv_cid     TYPE abp_behv_cid,
      i_responce TYPE TABLE OF string.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HDFC_INCOMING_HTTP_SRV IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

   DATA(req) = request->get_form_fields(  ).

    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

    DATA(body)  = request->get_text(  )  .
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
    REPLACE ALL OCCURRENCES OF 'Vl' IN wa_pay-virtualaccount WITH ''.
    REPLACE ALL OCCURRENCES OF 'vL' IN wa_pay-virtualaccount WITH ''.
    REPLACE ALL OCCURRENCES OF 'vl' IN wa_pay-virtualaccount WITH ''.
    REPLACE ALL OCCURRENCES OF 'VL' IN wa_pay-virtualaccount WITH ''.
*    REPLACE ALL OCCURRENCES OF 'vl' IN wa_pay-virtualaccount WITH ''.

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
    response->set_text( responce ).



  endmethod.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.
   data(body) = ''.
  ENDMETHOD.
ENDCLASS.
