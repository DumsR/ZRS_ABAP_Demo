class zph_dr_bp_util definition
  public
  create public .

public section.
    interfaces: if_oo_adt_classrun
     , if_oo_adt_classrun_out.   "non implented
    types:
        begin of ty_bpBase
    ,       partner            type but000-partner
    ,       name_first      type but000-name_first
    ,       name_last       type but000-name_last
    ,       type                 type but000-type
    ,       persnumber    type but000-persnumber
    ,       addrcomm     type but000-addrcomm
    ,   end of ty_bpBase
    ,   begin of ty_bpAdr
    ,       partner            type but000-partner
    ,       addrNumber  type but020-addrnumber
    ,   end of ty_bpAdr
    .constants:
        c_LF type abap_char1 value cl_abap_char_utilities=>newline
    .data:
        mv_bp_id          type but000-partner  read-only
    ,   ms_bpBase       type ty_bpBase read-only
    ,   ms_bpAdrs       type ty_bpAdr  read-only
    ,   mx_err               type ref to zph_dr_cx_msg
    .methods:
        constructor    "no param for F9 !
    ,   read_base
            importing iv_ID  type but000-partner optional
            returning value(rs_bpBase) type ty_bpBase
            raising zph_dr_cx_msg
    ,   read_adr_IDs
            returning value(rs_bpAdrs) type ty_bpAdr
            raising zph_dr_cx_msg
    .
protected section.
    methods:
        format_bpID
            importing id_in type simple "numc10
            returning value(bpID) type  but000-partner
    .
private section.
endclass.
class zph_dr_bp_util implementation.
**********************************************************************
method constructor.
    mx_err = new #(  ).
endmethod.
**********************************************************************
method read_base.
    if iv_ID is supplied.
        mv_bp_id = format_bpID( iv_ID ).
        endif.
    check mv_bp_id is not initial.

    select single * from but000
        where partner = @mv_bp_id
        into corresponding fields of @rs_bpBase.

    if sy-subrc is initial.
        ms_bpBase = rs_bpBase.
*    else.       "No Partner found (&1 &2 &3 &4 )
        message w001 with mv_bp_id into data(msg).
        mx_err->grab_syMsg(  ).
        endif.
endmethod.
**********************************************************************
method read_adr_IDs.
    check ms_bpBase is not initial.

    select single from BUT020
        fields partner, addrNumber
        where partner = @ms_bpBase-partner
        into corresponding fields of @rs_bpAdrs.

    if sy-subrc is initial.
        ms_bpAdrs = rs_bpAdrs.
*    else.       "No Address found (&1 &2 &3 &4 )
        message w002 with mv_bp_id into data(msg).
        mx_err->raise_from_sy(  ).
        endif.
endmethod.
**********************************************************************
method format_bpID.
    data lv_id type n length 10.
    lv_id = id_in.
*    overlay lv_id with '0000000000'.
    bpID = lv_id.
endmethod.
**********************************************************************
method if_oo_adt_classrun~main.             "only via F9 (<console)
    try.
        if mv_bp_id is initial.
            mv_bp_id = format_bpID( 21 ).
            endif.


        out->write( |Object ZPD_dr_bp_util{ c_LF } ... start with BP: { mv_bp_id }| ).
        data(bpInfo) = read_base( mv_bp_id ).
        out->write( bpInfo ).

        data(bpAdrs) = read_adr_IDs(  ).
        out->write( |{ c_LF }Addresses for BP { mv_bp_id }| ).
        out->write( bpAdrs ).

    catch zph_dr_cx_msg into data(cx).
        loop at cx->mt_msgs assigning field-symbol(<msg>).
            out->write( <msg>  ).
*            cl_demo_output=>display( <msg> ).
        endloop.
    endtry.
endmethod.
**********************************************************************

endclass.
