class ZCL_HDFC_INCM2 definition
  public
  create public .

public section.

      METHODS:
      sa_doc
      importing body type string
                acc_doc type I_OperationalAcctgDocItem-AccountingDocument
                transactionid type zbank_data1-transactionid.

      CLASS-DATA:
      lv_cid     TYPE abp_behv_cid,
      i_responce TYPE TABLE OF string.

    DATA:lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
         wa_je_deep LIKE LINE OF lt_je_deep.

    DATA :ar_item LIKE wa_je_deep-%param-_aritems[],
          gl_item LIKE wa_je_deep-%param-_glitems[].

     INTERFACES if_http_service_extension .
     INTERFACES if_oo_adt_classrun .

protected section.
private section.
ENDCLASS.



CLASS ZCL_HDFC_INCM2 IMPLEMENTATION.


  method IF_HTTP_SERVICE_EXTENSION~HANDLE_REQUEST.

*    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).

         TYPES :  BEGIN OF TY_TAB,
                      transactionid(25)     Type  C,
                      creditdatetime(20)    Type  C,
                      fromaccountnumber(70) Type  C,
                      frombankname(100)     Type  C,
                      remittername(100)     Type  C,
                      utr(22)               Type  C,
                      chequeno(22)          Type  C,
                      narration(150)        Type  C,
                      virtualaccount(25)    Type  C,
                      amount(16)            Type  P DECIMALS 2,
                      mmid(100)             Type  C,
                      profit_cent(10)       Type  C,
                      cust_no(10)           Type  C,
                      transfermode(10)      Type  C,
                      journalentryno(10)    Type  C,
                      error(250)            Type  C,
                      businessplace(4)      Type  C,
                END OF TY_TAB.

      DATA: ITAB TYPE TABLE OF TY_TAB,
            WTAB TYPE TY_TAB.
      DATA : it_pay TYPE TABLE OF   zbank_data1,
             wa_pay LIKE LINE OF it_pay.

      TYPES  : BEGIN OF TY1,
                selectedRows LIKE ITAB,
               END OF TY1.

      DATA: WER TYPE TY1 .


    DATA(body)  = request->get_text(  )  .

       /ui2/cl_json=>deserialize( EXPORTING json = body   CHANGING data = WER  ).

*  DATA(RESULT)  = zcl_acc_post_bapi_sss=>accounting_post( itab = wer )  .

LOOP AT WER-selectedrows INTO DATA(WA).

 IF WA-journalentryno IS INITIAL.

    TRY.
        lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.

   SELECT SINGLE * FROM zbank_data1 WITH PRIVILEGED ACCESS WHERE utr = @WA-transactionid  INTO @DATA(it_alredy).
   SELECT SINGLE * FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS WHERE AccountingDocument = @WA-journalentryno  INTO @DATA(LV).


  DATA amount LIKE WA-amount.
      amount = -1 * WA-amount.

   IF it_alredy IS INITIAL.

      wa_je_deep-%cid   = lv_cid.
      wa_je_deep-%param = VALUE #( companycode                  =  '1000'  "WA-virtualaccount+0(4)
                                   documentreferenceid          =  WA-utr
                                   createdbyuser                = 'HDFC Bank'
                                   businesstransactiontype      = 'RFBU'
                                   accountingdocumenttype       = 'DZ'
                                   documentdate                 = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|
                                   postingdate                  = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|

                                   accountingdocumentheadertext = WA-transactionid
                                   jrnlentrycntryspecificref2   = WA-transactionid ).



      SELECT SINGLE businesspartner, banknumber FROM i_businesspartnerbank WITH PRIVILEGED ACCESS WHERE  bankaccount = @WA-virtualaccount
      INTO @DATA(businesspartner).

      SELECT SINGLE housebank from  i_housebank WITH PRIVILEGED ACCESS  WHERE BankInternalID = @businesspartner-BankNumber
              INTO @DATA(housebank).


      ar_item =  VALUE #( (
                          glaccountlineitem   = '010'
                          housebank           = housebank
                          customer            = businesspartner-BusinessPartner  "'5500000060'
                          housebankaccount    = WA-fromaccountnumber
                          documentitemtext    = WA-narration
                          assignmentreference = WA-utr
                          businessplace       = WA-businessplace
                          Reference1IDByBusinessPartner = WA-profit_cent
                          Reference2IDByBusinessPartner = WA-virtualaccount
                          _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                           journalentryitemamount = amount
                                                           currency               = 'INR' ) ) ) ).

  APPEND LINES OF ar_item  TO wa_je_deep-%param-_aritems.

      gl_item =  VALUE #( ( glaccountlineitem   = '020'
                            glaccount           = '12500170'
                            businessplace       =  WA-businessplace
                            profitcenter        =  WA-profit_cent      "WA-businessplace
                            valuedate           =  |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|
                            documentitemtext    =  WA-narration
                            assignmentreference =  WA-utr
                            housebank           =  housebank     " 'HDF11'
*                            housebankaccount    =  wa_pay-fromaccountnumber
                            _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                             journalentryitemamount = WA-amount
                                                             currency               = 'INR' ) ) ) ).

      APPEND LINES OF gl_item TO wa_je_deep-%param-_glitems.

      APPEND wa_je_deep TO lt_je_deep.
      CLEAR:wa_je_deep,gl_item,ar_item.

      MODIFY ENTITIES OF i_journalentrytp
      ENTITY journalentry
      EXECUTE post FROM lt_je_deep
      FAILED DATA(ls_failed_deep)
      REPORTED DATA(ls_reported_deep)
      MAPPED DATA(ls_mapped_deep).

      TYPES:BEGIN OF ty_generic ,
              transactionid TYPE string,
              code          TYPE string,
              status        TYPE string,
            END OF ty_generic.

      DATA: generic TYPE ty_generic.
      DATA: res     TYPE ty_generic.

      IF ls_failed_deep IS NOT INITIAL.
        LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
          IF sy-tabix <> 1.
            IF <ls_reported_deep>-%msg->if_t100_dyn_msg~msgty = 'E'.
              DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_longtext( ).
              CONCATENATE ' Error :-' lv_result INTO DATA(responce) .
              APPEND responce TO i_responce.
              CLEAR responce.

              res-transactionid = ''.
              res-code = 400.
              res-status =  <ls_reported_deep>-%msg->if_message~get_longtext( ).

              wa_pay-transactionid     =  WA-transactionid    .
              wa_pay-profit_cent       =  WA-profit_cent      .
              wa_pay-cust_no           =  WA-cust_no          .
              wa_pay-creditdatetime    =  WA-creditdatetime   .
              wa_pay-creditdate        =  WA-creditdatetime+0(10) .
              wa_pay-fromaccountnumber =  WA-fromaccountnumber.
              wa_pay-frombankname      =  WA-frombankname     .
              wa_pay-remittername      =  WA-remittername     .
              wa_pay-utr               =  WA-utr              .
              wa_pay-chequeno          =  WA-chequeno         .
              wa_pay-narration         =  WA-narration        .
              wa_pay-virtualaccount    =  WA-virtualaccount   .
              wa_pay-amount            =  WA-amount           .
              wa_pay-mmid              =  WA-mmid             .
              wa_pay-profit_cent       =  WA-profit_cent      .
              wa_pay-cust_no           =  WA-cust_no          .
              wa_pay-transfermode      =  WA-transfermode     .
              wa_pay-journalentryno    =  WA-journalentryno   .
              wa_pay-error             =  lv_result           .
              wa_pay-businessplace     =  WA-businessplace    .
              MODIFY zbank_data1 FROM  @wa_pay.

            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.

        COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).

        COMMIT ENTITIES END.

        LOOP AT lt_commit_reported-journalentry INTO DATA(w).
          IF w-%msg->if_t100_dyn_msg~msgty = 'S'.
            responce  = |Accounting Document :- { w-%msg->if_t100_dyn_msg~msgv2+0(10) } Generated.|.
            DATA(RESULT) = responce.
            APPEND responce TO i_responce.
            CLEAR responce.
            wa_pay-journalentryno = w-%msg->if_t100_dyn_msg~msgv2+0(10).
            res-transactionid = w-%msg->if_t100_dyn_msg~msgv2+0(10).
            res-code = 200.
            res-status = 'Success'.

            wa_pay-transactionid     =  WA-transactionid    .
            wa_pay-profit_cent       =  WA-profit_cent      .
            wa_pay-cust_no           =  businesspartner-BusinessPartner .
            wa_pay-creditdatetime    =  WA-creditdatetime   .
            wa_pay-creditdate        =  WA-creditdatetime+0(10) .
            wa_pay-fromaccountnumber =  WA-fromaccountnumber.
            wa_pay-frombankname      =  WA-frombankname     .
            wa_pay-remittername      =  WA-remittername     .
            wa_pay-utr               =  WA-utr              .
            wa_pay-chequeno          =  WA-chequeno         .
            wa_pay-narration         =  WA-narration        .
            wa_pay-virtualaccount    =  WA-virtualaccount   .
            wa_pay-amount            =  WA-amount           .
            wa_pay-mmid              =  WA-mmid             .
            wa_pay-profit_cent       =  WA-profit_cent      .
            wa_pay-transfermode      =  WA-transfermode     .
            wa_pay-error             =  ''                  .
            wa_pay-businessplace     =  WA-businessplace    .

            MODIFY zbank_data1 FROM  @wa_pay .
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.


    IF it_alredy IS NOT INITIAL.
      res-transactionid = it_alredy-journalentryno.
*      res-transactionid = it_alredy-accountingdocument.
      res-code = 200.
      res-status = 'Success'.
      CLEAR : it_alredy, lt_je_deep.
    ENDIF.

    DATA:json TYPE REF TO if_xco_cp_json_data.
    CLEAR : responce, lt_je_deep.

    xco_cp_json=>data->from_abap(
      EXPORTING
        ia_abap      = res "i_responce
      RECEIVING
        ro_json_data = json ).
    json->to_string(
      RECEIVING
        rv_string = responce ).

    REPLACE ALL OCCURRENCES OF 'CODE'  IN responce WITH 'code'.
    REPLACE ALL OCCURRENCES OF 'STATUS'  IN responce WITH 'status'.
    REPLACE ALL OCCURRENCES OF 'TRANSACTIONID'  IN responce WITH 'transactionid'.
    response->set_text( responce ).

    IF ls_failed_deep IS NOT INITIAL.
       response->set_text( responce ).
        ELSE.
         response->set_text( RESULT ).
          ENDIF.

 ELSE.
  RESULT = | Accounting Document ( { wa-journalentryno } ) already generated against this transaction.|.
  response->set_text( RESULT ).
   ENDIF.

IF wa_pay-journalentryno IS NOT INITIAL.
me->sa_doc( body          = body
            acc_doc       = wa_pay-journalentryno
            transactionid = wa_pay-transactionid ).
ENDIF.
 clear: housebank, businesspartner, LV.
 ENDLOOP.



  ENDMETHOD.


  METHOD IF_OO_ADT_CLASSRUN~MAIN.

  ENDMETHOD.


  METHOD SA_DOC.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" SA DOCUMENT

DATA:lt_je_deep1 TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
         wa_je_deep1 LIKE LINE OF lt_je_deep1.

         TYPES :  BEGIN OF TY_TAB,
                      transactionid(25)     Type  C,
                      creditdatetime(20)    Type  C,
                      fromaccountnumber(70) Type  C,
                      frombankname(100)     Type  C,
                      remittername(100)     Type  C,
                      utr(22)               Type  C,
                      chequeno(22)          Type  C,
                      narration(150)        Type  C,
                      virtualaccount(25)    Type  C,
                      amount(16)            Type  P DECIMALS 2,
                      mmid(100)             Type  C,
                      profit_cent(10)       Type  C,
                      cust_no(10)           Type  C,
                      transfermode(10)      Type  C,
                      journalentryno(10)    Type  C,
                      error(250)            Type  C,
                      businessplace(4)      Type  C,
                END OF TY_TAB.

      DATA: ITAB TYPE TABLE OF TY_TAB,
            WTAB TYPE TY_TAB.
      DATA : it_pay TYPE TABLE OF   zbank_data1,
             wa_pay LIKE LINE OF it_pay.

      TYPES  : BEGIN OF TY1,
                selectedRows LIKE ITAB,
               END OF TY1.

      DATA: WER TYPE TY1 .


*    DATA(body)  = request->get_text(  )  .

       /ui2/cl_json=>deserialize( EXPORTING json = body   CHANGING data = WER  ).

LOOP AT WER-selectedrows INTO DATA(WA) WHERE transactionid = transactionid.

* IF WA-journalentryno IS INITIAL.

    TRY.
        lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.

   SELECT SINGLE * FROM zbank_data1 WITH PRIVILEGED ACCESS WHERE utr = @WA-transactionid  INTO @DATA(it_alredy).
   SELECT SINGLE * FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS WHERE AccountingDocument = @WA-journalentryno  INTO @DATA(LV).


  DATA amount LIKE WA-amount.
      amount = -1 * WA-amount.    IF it_alredy IS INITIAL.


  wa_je_deep1-%cid   = lv_cid.
     wa_je_deep1-%param = VALUE #( companycode                  = WA-virtualaccount+0(4)
                                   documentreferenceid          =  acc_doc
                                   createdbyuser                = 'HDFC Bank'
                                   businesstransactiontype      = 'RFBU'
                                   accountingdocumenttype       = 'DZ'
                                   documentdate                 = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|
                                   postingdate                  = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|

                                   accountingdocumentheadertext = WA-transactionid
                                   jrnlentrycntryspecificref2   = WA-transactionid ).


      SELECT SINGLE businesspartner, banknumber FROM i_businesspartnerbank WITH PRIVILEGED ACCESS WHERE  bankaccount = @WA-virtualaccount
      INTO @DATA(businesspartner).

      SELECT SINGLE housebank from  i_housebank WITH PRIVILEGED ACCESS  WHERE BankInternalID = @businesspartner-BankNumber
              INTO @DATA(housebank).


      gl_item =  VALUE #( ( glaccountlineitem   = '010'
                            glaccount           = '12500111'   "'12500160'
                            businessplace       = 'UP01'         "1001'  "WA-businessplace
                            profitcenter        = '1001'  "WA-businessplace
                            valuedate           = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|
                            documentitemtext    = WA-narration
                            assignmentreference = WA-utr
                            housebank           = 'HD11' " housebank "'HDF11'
                            housebankaccount    = 'HD11' "wa_pay-fromaccountnumber
                            _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                             journalentryitemamount = WA-amount
                                                             currency               = 'INR' ) ) ) ).



      APPEND LINES OF gl_item TO wa_je_deep1-%param-_glitems.

        gl_item =  VALUE #( ( glaccountlineitem   = '020'
                            glaccount           = '12500170'
                            businessplace       = WA-businessplace
                            profitcenter        = WA-profit_cent     "WA-businessplace
                            valuedate           = |{ WA-creditdatetime+0(4) }{ WA-creditdatetime+5(2) }{ WA-creditdatetime+8(2) }|
                            documentitemtext    = WA-narration
                            assignmentreference = WA-utr
                            housebank           = 'HD11' "housebank  "'HDF11'
                            housebankaccount    = 'HD11' "wa_pay-fromaccountnumber
                            _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                             journalentryitemamount = WA-amount * -1
                                                             currency               = 'INR' ) ) ) ).

      APPEND LINES OF gl_item TO wa_je_deep1-%param-_glitems.


      APPEND wa_je_deep1 TO lt_je_deep1.
      CLEAR:wa_je_deep1,gl_item,ar_item.

     MODIFY ENTITIES OF i_journalentrytp
      ENTITY journalentry
      EXECUTE post FROM lt_je_deep1
      FAILED DATA(ls_failed_deep)
      REPORTED DATA(ls_reported_deep)
      MAPPED DATA(ls_mapped_deep).

      TYPES:BEGIN OF ty_generic ,
              transactionid TYPE string,
              code          TYPE string,
              status        TYPE string,
            END OF ty_generic.

      DATA: generic TYPE ty_generic.
      DATA: res     TYPE ty_generic.

      IF ls_failed_deep IS NOT INITIAL.
        LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
          IF sy-tabix <> 1.
            IF <ls_reported_deep>-%msg->if_t100_dyn_msg~msgty = 'E'.
              DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_longtext( ).
              CONCATENATE ' Error :-' lv_result INTO DATA(responce1) .
              APPEND responce1 TO i_responce.
              CLEAR responce1.

              res-transactionid = ''.
              res-code = 400.
              res-status =  <ls_reported_deep>-%msg->if_message~get_longtext( ).

            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.

       COMMIT ENTITIES BEGIN
        RESPONSE OF i_journalentrytp
        FAILED DATA(lt_commit_failed)
        REPORTED DATA(lt_commit_reported).

        COMMIT ENTITIES END.


        LOOP AT lt_commit_reported-journalentry INTO DATA(w1).
          IF w1-%msg->if_t100_dyn_msg~msgty = 'S'.
            responce1  = |Accounting Document :- { w1-%msg->if_t100_dyn_msg~msgv2+0(10) } Generated.|.
            DATA(RESULT1) = responce1.
            APPEND responce1 TO i_responce.
            CLEAR: responce1, lt_je_deep1.

          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
clear: housebank, businesspartner, LV.
ENDLOOP.
  ENDMETHOD.
ENDCLASS.
