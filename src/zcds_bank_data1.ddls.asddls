@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR BANK DATA1 TABLE'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED  }

define root view entity ZCDS_BANK_DATA1 as select from zbank_data1

{

 @UI.multiLineText: true  

   @UI.lineItem: [
    { position: 5  },
    { position: 10, type: #FOR_ACTION, dataAction: 'Bank_data',  label: 'Post 🏦', invocationGrouping: #CHANGE_SET },  
    { position: 10, type: #FOR_ACTION, dataAction: 'Business_Place',  label: 'Business Place', invocationGrouping: #CHANGE_SET, value: 'businessplace' },  
    { position: 10, type: #FOR_ACTION, dataAction: 'Profit_Center',  label: 'Profit Center', invocationGrouping: #CHANGE_SET, value: 'profit_cent' },  
 { type: #FOR_ACTION, dataAction: 'reject',  label: 'Reject ', invocationGrouping: #CHANGE_SET, position: 10  } ,
 
    { position: 10, label: 'Transaction ID'}]
      @UI.identification: [{ position:10 } ]
      @UI.selectionField: [{ position: 10 }]
      @Search.defaultSearchElement: true  
    key transactionid,
    
    @UI.lineItem      : [{ position: 20 }]
    @UI.identification: [{ position: 20 }]
    @EndUserText.label: 'Credit Date Time'
    key creditdatetime,
    
    @UI.lineItem      : [{ position: 30 }]
    @UI.identification: [{ position: 30 }]
    @EndUserText.label: 'From Acc Number'
    key fromaccountnumber,
    
    @UI.lineItem      : [{ position: 40 }]
    @UI.identification: [{ position: 40 }]
    @UI.selectionField: [{ position: 40 }]
    @EndUserText.label: 'From Bank Name'
    key frombankname,
    
    @UI.lineItem      : [{ position: 50 }]
    @UI.identification: [{ position: 50 }]
    @EndUserText.label: 'Remitter Name'
    key remittername,
    
    @UI.lineItem      : [{ position: 60 }]
    @UI.identification: [{ position: 60 }]
    @EndUserText.label: 'UTR No.'
    key utr,
    
    @UI.lineItem      : [{ position: 70 }]
    @UI.identification: [{ position: 70 }]
    @UI.selectionField: [{ position: 70 }]
    @EndUserText.label: 'Cheque No.'
    key chequeno,
    
    @UI.lineItem      : [{ position: 80 }]
    @UI.identification: [{ position: 80 }]
    @EndUserText.label: 'Narration'
    key narration,
    
    @UI.lineItem      : [{ position: 90 }]
    @UI.identification: [{ position: 90 }]
    @UI.selectionField: [{ position: 90 }]
    @EndUserText.label: 'Virtual Account'
    key virtualaccount,
    
    @UI.lineItem      : [{ position: 100 }]
    @UI.identification: [{ position: 100 }]
    @EndUserText.label: 'Amount'
    key amount,
    
    @UI.lineItem      : [{ position: 110 }]
    @UI.identification: [{ position: 110 }]
    @EndUserText.label: 'Mmid'
    key mmid,
    
    @UI.lineItem      : [{ position: 120 }]
    @UI.identification: [{ position: 120 }]
    @UI.selectionField: [{ position: 120 }]
    @EndUserText.label: 'Profit Center'
    key profit_cent,
    
    @UI.lineItem      : [{ position: 130 }]
    @UI.identification: [{ position: 130 }]
    @UI.selectionField: [{ position: 130 }]
    @EndUserText.label: 'Customer No.'
    key cust_no,
    
    @UI.lineItem      : [{ position: 140 }]
    @UI.identification: [{ position: 140 }]
    @UI.selectionField: [{ position: 140 }]
    @EndUserText.label: 'Transfer Mode'
    key transfermode,
    
    @UI.lineItem      : [{ position: 150 }]
    @UI.identification: [{ position: 150 }]
    @UI.selectionField: [{ position: 150 }]
    @EndUserText.label: 'Journal Entry No.'
    key journalentryno,
    
    @UI.lineItem      : [{ position: 160 }]
    @UI.identification: [{ position: 160 }]
    @EndUserText.label: 'Error'
    key error,
    
    @UI.lineItem      : [{ position: 170 }]
    @UI.identification: [{ position: 170 }]
    @UI.selectionField: [{ position: 170 }]
    @EndUserText.label: 'Business Place'
    key businessplace  
    

   
}
