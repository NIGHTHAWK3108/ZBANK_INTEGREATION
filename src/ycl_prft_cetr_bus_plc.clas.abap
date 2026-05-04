CLASS ycl_prft_cetr_bus_plc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS YCL_PRFT_CETR_BUS_PLC IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

* data: lt_business1 type table of zbank_data1.
*    lt_business1 = value #(
*
*
*      ( s_no = '1'       bus_plc = 'UP02'   profit_center = '1004' )
*      ( s_no = '2'       bus_plc = 'UP01'   profit_center = '1001' )
*      ( s_no = '3'       bus_plc = 'UP01'   profit_center = '1002' )
*      ( s_no = '4'       bus_plc = 'UP01'   profit_center = '1003' )
*      ( s_no = '5'       bus_plc = 'JH01'   profit_center = '1019' )
*      ( s_no = '6'       bus_plc = 'BH02'   profit_center = '1017' )
*      ( s_no = '7'       bus_plc = 'UP04'   profit_center = '1013' )
*      ( s_no = '8'       bus_plc = 'UP03'   profit_center = '1005' )
*      ( s_no = '9'       bus_plc = 'UP03'   profit_center = '1006' )
*      ( s_no = '10'       bus_plc = 'UP03'   profit_center = '1007' )
*      ( s_no = '11'       bus_plc = 'UP03'   profit_center = '1008' )
*      ( s_no = '12'       bus_plc = 'UP03'   profit_center = '1009' )
*      ( s_no = '13'       bus_plc = 'UP03'   profit_center = '1010' )
*      ( s_no = '14'       bus_plc = 'UP03'   profit_center = '1011' )
*      ( s_no = '15'       bus_plc = 'WB01'   profit_center = '1020' )
*      ( s_no = '16'       bus_plc = 'BH03'   profit_center = '1018' )
*      ( s_no = '17'       bus_plc = 'BH01'   profit_center = '1015' )
*      ( s_no = '18'       bus_plc = 'BH01'   profit_center = '1016' )
*      ( s_no = '19'       bus_plc = 'MP01'   profit_center = '1021' )
*      ( s_no = '20'       bus_plc = 'BH04'   profit_center = '1022' )
*      ( s_no = '21'      bus_plc = '2001'   profit_center = '2001' )
*      ( s_no = '22'      bus_plc = '3001'   profit_center = '3001' )
*      ( s_no = '23'      bus_plc = '3002'   profit_center = '3002' )
*      ( s_no = '24'      bus_plc = '3003'   profit_center = '3003' )
*
*( transactionid = '0000000000000012942500002'
*   creditdatetime = '2025-04-12 11:17:21'
*   fromaccountnumber = '2211211938295804'
*   virtualaccount = 'RMPLTDC000185' )
* ).
**
*      MODIFY zbank_data1 from table @lt_business1 .


DELETE FROM zbank_data1 .



ENDMETHOD.
ENDCLASS.
