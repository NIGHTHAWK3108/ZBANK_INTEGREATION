@EndUserText.label: 'CDS FOR SERVICE'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Ycds_Bank_Data_Inc as select from zbank_data1
{
    
    key transactionid    ,
    creditdatetime        ,
    fromaccountnumber     ,
    frombankname          ,
    remittername          ,
    utr                   ,
    chequeno              ,
    narration             ,
    virtualaccount        ,
    amount                ,
    mmid                  ,
    profit_cent           ,
    cust_no               ,
    transfermode          ,
    journalentryno        ,
    error                 ,
    businessplace         ,
    creditdate 
} 
where journalentryno = ''

