@AbapCatalog.sqlViewName: 'ZBUSINESS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS FOR BUSINESS PLACE DROP DOWN'
@Metadata.ignorePropagatedAnnotations: true
define view ZBUSINESS_PLACE as select from I_BusinessPlaceVH
{

  @Search.defaultSearchElement: true
  @EndUserText.label: 'Business Place'
   key BusinessPlace,
   BusinessPlaceDescription
}
