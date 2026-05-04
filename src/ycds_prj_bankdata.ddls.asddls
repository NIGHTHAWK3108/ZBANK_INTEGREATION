@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDs For prjoection'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YCDS_PRJ_BANKDATA
  provider contract transactional_query 
as projection on Ycds_Bank_Data_Inc
{
    key transactionid,
    creditdatetime,
    fromaccountnumber,
    frombankname,
    remittername,
    utr,
    chequeno,
    narration,
    virtualaccount,
    amount,
    mmid,
    profit_cent,
    cust_no,
    transfermode,
    journalentryno,
    error,
    businessplace
}
