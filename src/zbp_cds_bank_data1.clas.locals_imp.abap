CLASS lhc_ZCDS_BANK_DATA1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zcds_bank_data1 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zcds_bank_data1 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zcds_bank_data1.

    METHODS Bank_data FOR MODIFY
      IMPORTING keys FOR ACTION zcds_bank_data1~Bank_data.

    METHODS reject FOR MODIFY
      IMPORTING keys FOR ACTION zcds_bank_data1~reject.

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
                      amount                Type  I_OperationalAcctgDocItem-AmountInCompanyCodeCurrency,
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
       DATA : item_text(5) TYPE c.

    CLASS-DATA:
      lv_cid     TYPE abp_behv_cid,
      i_responce TYPE TABLE OF string.

    DATA:lt_je_deep TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post,
         wa_je_deep LIKE LINE OF lt_je_deep.

    DATA :ar_item LIKE wa_je_deep-%param-_aritems[],
          gl_item LIKE wa_je_deep-%param-_glitems[].


ENDCLASS.

CLASS lhc_ZCDS_BANK_DATA1 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Start of Posting Bank Data
  METHOD Bank_data.

*    response->set_header_field( i_name = 'Access-Control-Allow-Origin' i_value = '*' ).
*    response->set_header_field( i_name = 'Access-Control-Allow-Credentials' i_value = 'true' ).


  READ ENTITIES OF zcds_bank_data1 IN LOCAL MODE
  ENTITY zcds_bank_data1
  ALL FIELDS WITH CORRESPONDING #( keys )
  RESULT dATA(RESY).

   MOVE-CORRESPONDING keys TO Itab  .

 LOOP AT Itab ASSIGNING FIELD-SYMBOL(<fg>)  .

   SELECT SINGLE * FROM zbank_data1 WITH PRIVILEGED ACCESS WHERE utr = @<fg>-transactionid  INTO @DATA(it_alredy).
   SELECT SINGLE * FROM I_OperationalAcctgDocItem WITH PRIVILEGED ACCESS WHERE AccountingDocument = @<fg>-journalentryno  INTO @DATA(LV).



    IF it_alredy IS INITIAL.

      wa_je_deep-%cid   = lv_cid.
      wa_je_deep-%param = VALUE #( companycode                  = LV-CompanyCode
                                   documentreferenceid          = <fg>-utr
                                   createdbyuser                = 'HDFC Bank'
                                   businesstransactiontype      = 'RFBU'
                                   accountingdocumenttype       = 'DZ'
                                   documentdate                 = LV-DocumentDate "wa_pay-creditdatetime
                                   postingdate                  = LV-PostingDate "wa_pay-creditdatetime
                                   accountingdocumentheadertext = <fg>-transactionid
                                   jrnlentrycntryspecificref2   = <fg>-transactionid


                                 ).

* DATA profit TYPE STRING .
*      IF wa_pay-virtualaccount+0(6) = 'RBLLTD'.
*        DATA(acc) = '01192560002451'.
*        comp_code = '1000'.
**        glaccount = '0001071181'.
*        glaccount = '0021100051'.
*        businessplace = '1100'.
*        profit = '100099'.
*item_text = wa_pay-narration.
*        IF wa_pay-virtualaccount+15(3) = 'DAP'.
*          profit = '3000UIIDAP'.
*          item_text = 'DAP'.
*          item_text = wa_pay-narration.
*        ELSEIF wa_pay-virtualaccount+15(3) = 'NBP'.
*          profit = '30000UIINB'.
**          item_text = 'NBP'.
* item_text = wa_pay-narration.
*        ELSEIF wa_pay-virtualaccount+15(3) = 'NPK'.
*          profit = '3000UIINPK'.
**          item_text = 'NPK'.
* item_text = wa_pay-narration.
*        ELSEIF wa_pay-virtualaccount+15(3) = 'SSP'.
*          profit = '3000UIISSP'.
**          item_text = 'SSP'.
* item_text = wa_pay-narration.
*        ENDIF.
*
*      ELSEIF wa_pay-virtualaccount+0(6) = 'MBAPL3'.
*        acc = '50200005429048'.
*
*
*      ELSEIF wa_pay-virtualaccount+0(6) = 'MBAPL4'..
*        acc = '04492320000069'.
*
*      ELSEIF wa_pay-virtualaccount+0(3) = 'KPL'.
*        acc = '50200007423685'.
*        glaccount = '0001071161'.
*        businessplace = 'KPMP'.
*      ENDIF.

      SELECT SINGLE b~housebank
             FROM i_bank_2 WITH PRIVILEGED ACCESS AS a
             INNER JOIN i_housebank WITH PRIVILEGED ACCESS AS b ON ( b~bankinternalid = a~bankinternalid )
             WHERE a~bank = @<fg>-fromaccountnumber
              INTO @DATA(housebank).

*   housebank = 'HDF51'  .


*    SELECT SINGLE b~housebank
*           FROM i_bank_2 WITH PRIVILEGED ACCESS AS a
*           INNER JOIN i_housebank WITH PRIVILEGED ACCESS AS b ON ( b~bankinternalid = a~bankinternalid )
*           WHERE a~bank = @wa_pay-virtualaccount INTO @DATA(housebank).

*    IF wa_pay-debitcredit = 'Credit' .
      DATA amount LIKE <fg>-amount.
      amount = -1 * <fg>-amount.
*    ELSE .
*      amount =  wa_pay-amount.
*    ENDIF.

      SELECT SINGLE businesspartner FROM i_businesspartnerbank WITH PRIVILEGED ACCESS WHERE  bankaccount = @<fg>-virtualaccount
      INTO @DATA(businesspartner).

      ar_item =  VALUE #( (
                          glaccountlineitem   = '010'
                          housebank           = housebank
                          customer            = businesspartner
                          housebankaccount    = housebank" wa_pay-fromaccountnumber
                          documentitemtext    = <fg>-narration
                          assignmentreference = <fg>-utr
                          businessplace       = <fg>-businessplace
                          _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                           journalentryitemamount = amount
                                                           currency               = 'INR' ) ) ) ).

      APPEND LINES OF ar_item  TO wa_je_deep-%param-_aritems.

      gl_item =  VALUE #( ( glaccountlineitem   = '020'
                            glaccount           = LV-glaccount
                            businessplace       = <fg>-businessplace
                            profitcenter        = <fg>-profit_cent
                            valuedate           = <fg>-creditdatetime+0(8) "wa_pay-creditdatetime
                            documentitemtext    = <fg>-narration
                            assignmentreference = <fg>-utr
                            housebank           = housebank
                            housebankaccount    = housebank "wa_pay-fromaccountnumber
                            _currencyamount     = VALUE #( ( currencyrole           = '00'
                                                             journalentryitemamount = <fg>-amount
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
      DATA:generic TYPE ty_generic.
*    TYPES:BEGIN OF ty_res,
**            genericcorporatealertresponse LIKE  generic,
*          END OF ty_res.
*    DATA:res TYPE ty_res.
      DATA:res TYPE ty_generic.

      IF ls_failed_deep IS NOT INITIAL.
        LOOP AT ls_reported_deep-journalentry ASSIGNING FIELD-SYMBOL(<ls_reported_deep>).
          IF sy-tabix <> 1.
            IF <ls_reported_deep>-%msg->if_t100_dyn_msg~msgty = 'E'.
              DATA(lv_result) = <ls_reported_deep>-%msg->if_message~get_longtext( ).
              CONCATENATE '$$$$ Error :-' lv_result INTO DATA(responce) .
              APPEND responce TO i_responce.
              CLEAR responce.

              res-transactionid = ''.
              res-code = 400.
              res-status =  <ls_reported_deep>-%msg->if_message~get_longtext( ).
              <fg>-error = lv_result.
*              wa_pay-profit_cent = profit.
*              wa_pay-cust_no = businesspartner.
*              MODIFY zbank_data1 FROM  @<fg> .
            ENDIF.
          ENDIF.
        ENDLOOP.
      ELSE.
*        COMMIT ENTITIES BEGIN
*        RESPONSE OF i_journalentrytp
*        FAILED DATA(lt_commit_failed)
*        REPORTED DATA(lt_commit_reported).
*        ...
*        COMMIT ENTITIES END.


*        LOOP AT lt_commit_reported-journalentry INTO DATA(w).
*          IF w-%msg->if_t100_dyn_msg~msgty = 'S'.
*            responce  = |$$$$ Document :-{ w-%msg->if_t100_dyn_msg~msgv2+0(10) } Generated|.
*            APPEND responce TO i_responce.
*            CLEAR responce.
*            wa_pay-journalentryno = w-%msg->if_t100_dyn_msg~msgv2+0(10).
*            res-transactionid = w-%msg->if_t100_dyn_msg~msgv2+0(10).
*            res-code = 200.
*            res-status = 'Success'.
**            wa_pay-profit_cent = profit.
**            wa_pay-cust_no = businesspartner.
*            MODIFY zbank_data1 FROM  @wa_pay .
*          ENDIF.
*        ENDLOOP.
      ENDIF.
    ENDIF.
    IF it_alredy IS NOT INITIAL.
      res-transactionid = it_alredy-journalentryno.
*      res-transactionid = it_alredy-accountingdocument.
      res-code = 200.
      res-status = 'Success'.
*      CLEAR : it_alredy, profit, businesspartner.
    ENDIF.

    DATA:json TYPE REF TO if_xco_cp_json_data.
    CLEAR:responce.

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
*    respone->set_text( responce ).


 ENDLOOP.
  ENDMETHOD.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" End of Posting Bank Data
  METHOD reject.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCDS_BANK_DATA1 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZCDS_BANK_DATA1 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
