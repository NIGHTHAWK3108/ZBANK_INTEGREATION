
@AbapCatalog.sqlViewName: 'ybus_profit'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Profit Center wise Business Place'
@Metadata.ignorePropagatedAnnotations: true

define view ZCDS_BUS_PLC as select from ZTB_PRFT_BUSI_PL
{
    key  s_no as SNo,
      bus_plc as BusPlc,
     profit_center as ProfitCenter
}
