*&---------------------------------------------------------------------*
*& Report zph_dr_bp_chg
*&---------------------------------------------------------------------*
*& Business Partner: Company > Person
*&---------------------------------------------------------------------*
REPORT zph_dr_bp_chg.

PARAMETERS:
  p_bpNmb TYPE but000-partner default 21.

data:
    bp      type ref to zph_dr_bp_util
.
**********************************************************************
START-OF-SELECTION.
try.
    bp = new #(  ).
*    bp->if_oo_adt_classrun~main( bp ).  "only via F9 (<console)

    data(bpInfo) = bp->read_base( p_bpNmb  ).
    data(bpAdrs) = bp->read_adr_IDs(  ).

catch cx_root into data(cx).
*   see bp->mx_err->mt_msgs
endtry.
    write / 'end of procssing ------------------------'.
    write /.
**********************************************************************
END-OF-SELECTION.
    write / 'Output-List  ----------------------------'.
    write: / |GP { bpInfo-partner } found|.
    write: /  'GP',
          5 'Typ',
        10 'Name',
        30 'PersNb',
        35 'bpAddr',
        45 'AdrC'.
    write: / bpInfo-partner,
          5 bpInfo-type,
        10 |{ bpInfo-name_first } { bpInfo-name_last }|,
        30 bpInfo-persnumber,
        35 bpInfo-addrcomm,
        45 bpAdrs-addrNumber.

    write /.    "write /.
    write / 'Message-List  ----------------------------'.
    write: / 'Typ/Nmb/msg-Cls', 20 'msgText'.
    loop at bp->mx_err->mt_msgs into data(msg).
       data(msgTxt) =  bp->mx_err->format_msg( msg ).
        write: / msg-type, msg-number, msg-id, 20 msgTxt.
    endloop.
