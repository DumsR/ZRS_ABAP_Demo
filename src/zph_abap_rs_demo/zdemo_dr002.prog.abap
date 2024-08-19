REPORT ZDEMO_DR002.

data port type /DMO/Airport.
*PARAMETERS:
*  p_cntry  type /DMO/AIRPORT-country default 'US'..
SELECT-OPTIONS:
 so_apID for port-airport_ID.


START-OF-SELECTION.
* select
  select * from /dmo/airport
    where airport_ID in @so_apID
    into table @data(myPorts).
  if sy-subrc is not INITIAL.
    write 'No airport found !!! '.
    endif.

end-of-SELECTION.
*  write ...
loop at myPorts into port.
  write: / port-airport_id, 20 port-name.

ENDLOOP.
