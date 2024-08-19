*&---------------------------------------------------------------------*
*& Report ZDEMO_DR001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEMO_DR001.

PARAMETERS:
  p_cntry  type /DMO/AIRPORT-country default 'US'..
*SELECT-OPTIONS so_cntry for /DMO/AIRPORT-COUNTRY.


START-OF-SELECTION.
* select
  select * from /dmo/airport
    where country = @p_cntry
    into table @data(myPorts).
  if sy-subrc is not INITIAL.
    write 'No airport found in US'.
    endif.

end-of-SELECTION.
*  write ...
loop at myPorts into data(port).
  write: / port-airport_id, 20 port-name.

ENDLOOP.
