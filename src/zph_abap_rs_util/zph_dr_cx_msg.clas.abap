class zph_dr_cx_msg definition
  public
  inheriting from cx_static_check
  final
  create public .

public section.
    interfaces:
        if_t100_dyn_msg
    ,   if_t100_message
    .
*    type-pool icon.    "
    constants:
        yes type abap_bool value abap_true
    ,   no  type abap_bool value abap_false
    ,   icon_green   type icon value icon_green_light
    ,   icon_yellow  type icon value icon_red_light
    .
    data:
        mv_msg          type BAPIRET2
    ,   mt_msgs         type BAPIRET2_T
    .
  methods:
        constructor
            importing
                textid like if_t100_message=>t100key optional
                previous like previous optional
    ,   grab_syMsg
    ,   raise_lastMsg
            raising zph_dr_cx_msg
    ,   raise_from_sy
            importing
                iv_function   type string optional
                add2buf        like yes default yes
                preferred parameter iv_function
            raising zph_dr_cx_msg
    ,   raise_from_bapiMsg
            importing
                msg  type BAPIRET2
            raising zph_dr_cx_msg
    ,   format_msg
            importing
                msgBapi  type bapiRet2
            returning
                value(msgTxt) type string
    .
**********************************************************************
protected section.
*    methods:
*        grab_syMsg
*    .
private section.
endclass.
class zph_dr_cx_msg implementation.
**********************************************************************
method constructor ##ADT_SUPPRESS_GENERATION.
    call method super->constructor
        exporting previous = previous.

    clear me->textid.
    if textid is initial.
      if_t100_message~t100key =
        if_t100_message=>default_textid.
    else.
      if_t100_message~t100key = textid.
    endif.
endmethod.
**********************************************************************
method format_msg.

    call function 'FORMAT_MESSAGE'
      exporting
        id        = msgBapi-id
        no       = msgBapi-number
        v1        = msgBapi-message_v1
        v2        = msgBapi-message_v2
        v3        = msgBapi-message_v3
        v4        = msgBapi-message_v4
         lang    = sy-langu
     importing
        msg       = msgTxt
      exceptions
        not_found = 1
        others    = 2.

*    check sy-subrc is initial.
*    type-pool icon.    "
*    case msgBapi-type.
*    when 'I'.     msgTxt = icon_green_light  && msgTxt.  "@08@
*    when 'W'.  msgTxt = icon_yellow_light && msgTxt.  "@09@
*    when 'E'.    msgTxt = icon_red_light      && msgTxt.  "@0A@
*    endcase.
endmethod.
**********************************************************************
method grab_syMsg.
    check sy-msgid is not initial
        and sy-msgno is not initial.

    mv_msg-id         = sy-msgid.
    mv_msg-type       = sy-msgty.
    mv_msg-number     = sy-msgno.
    mv_msg-message_v1 = sy-msgv1.
    mv_msg-message_v2 = sy-msgv2.
    mv_msg-message_v3 = sy-msgv3.
    mv_msg-message_v4 = sy-msgv4.
    case sy-msgTy.
    when 'I'.    mv_msg-parameter = icon_green_light.
    when 'W'.  mv_msg-parameter = icon_yellow_light.
    when 'E'.    mv_msg-parameter = icon_red_light.
    endcase.
    append mv_msg to mt_msgs.
endmethod.
**********************************************************************
method raise_lastMsg.
    check mv_msg is not initial.
    raise_from_bapiMsg( mv_msg ).
endmethod.
**********************************************************************
method raise_from_sy.

    clear mv_msg.
    grab_syMsg(  ).
    check mv_msg is not initial.

    raise_from_bapiMsg( mv_msg ).

*    data bapiMsg type bapiRet2.
*        if log is bound.
*            bapiMsg = log->add_sys_msg_asBapi( 'E' ).
*        else.
*            endif.
*    else.
*        bapiMsg-id  = '/RLBOOE/VIM_TRAVEL'.
*        bapiMsg-number = 000.
*        bapiMsg-message_v1 = iv_function.
*        bapiMsg-message_v2 = sy-subrc.
**       Fehler während FB &1 - Ausnahme / Fehlercode = &2
*        if add2buf = yes and log is bound.
*            log->add_bapi_msg2( msg = bapiMsg  iv_level = 'E' ).
*            endif.
*    endif.
endmethod.
**********************************************************************
method raise_from_bapiMsg.
    mv_msg = msg.
    append mv_msg to mt_msgs.

    data t100 type scx_t100key.
    t100-msgid  = msg-id.
    t100-msgno = msg-number.
    t100-attr1     =  msg-message_v1.
    t100-attr2     =  msg-message_v2.
    t100-attr3     =  msg-message_v3.
    t100-attr4     =  msg-message_v4.

    raise exception type zph_dr_cx_msg
        exporting textid = t100.
endmethod.
**********************************************************************
endclass.
