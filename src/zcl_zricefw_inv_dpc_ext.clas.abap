class ZCL_ZRICEFW_INV_DPC_EXT definition
  public
  inheriting from ZCL_ZRICEFW_INV_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_PROCESS
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods ATCDETAILSSET_GET_ENTITYSET
    redefinition .
  methods DEPENDENTOBJECTS_GET_ENTITYSET
    redefinition .
  methods JOBLOGSET_GET_ENTITYSET
    redefinition .
  methods PACKAGELISTSET_GET_ENTITYSET
    redefinition .
  methods REMEDIATESET_CREATE_ENTITY
    redefinition .
  methods REMEDIATESET_GET_ENTITY
    redefinition .
  methods RICEFWLISTSET_GET_ENTITYSET
    redefinition .
  methods TRANSPORTLISTSET_GET_ENTITYSET
    redefinition .
  methods BEFAFTERDETAILSS_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZRICEFW_INV_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_begin.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_BEGIN
*  EXPORTING
*    IT_OPERATION_INFO =
**  CHANGING
**    cv_defer_mode     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
*****************    LOOP AT it_operation_info INTO DATA(ls_operation_info).
*****************      IF ls_operation_info-entity_set  EQ 'RemediateSet' .
*****************        cv_defer_mode = abap_true.
*****************        EXIT.
*****************      ENDIF.
*****************    ENDLOOP.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_end.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CHANGESET_END
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.


    COMMIT WORK AND WAIT.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~changeset_process.

************************    DATA: ls_changeset_request  TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_request,
************************          ls_changeset_response TYPE /iwbep/if_mgw_appl_types=>ty_s_changeset_response,
************************          lv_entity_type        TYPE string,
************************          lo_create_context     TYPE REF TO /iwbep/if_mgw_req_entity_c,
************************          ls_item               TYPE zcl_zricefw_inv_mpc=>ts_remediate,
************************          lt_message           TYPE zcl_code_remediation=>tt_message,
************************          ls_message like LINE OF lt_message,
************************          l_ref                 TYPE REF TO zcl_code_remediation,
************************          obj_name              TYPE sobj_name,
************************          ls_transport          TYPE trkorr,
************************          ls_package            TYPE devclass,
************************          lo_message_container  TYPE REF TO /iwbep/if_message_container,
************************          lv_message TYPE BAPI_MSG,
************************          ls_header             TYPE ihttpnvp,
************************          lv_m                  TYPE string,
************************          lv_line               TYPE i,
************************          lv_error              TYPE boolean VALUE abap_false.
************************
************************    CONSTANTS: lc_e TYPE c VALUE 'E',
************************               lc_s TYPE c VALUE 'S'.
************************
************************
************************    l_ref =  zcl_code_remediation=>get_instance( ).
************************    DESCRIBE TABLE it_changeset_request LINES lv_line.
************************    lv_m = 'Remediation Failed for : '.
************************
************************    LOOP AT it_changeset_request INTO ls_changeset_request.
************************
************************      lo_create_context ?= ls_changeset_request-request_context.
************************      lv_entity_type = lo_create_context->get_entity_type_name( ).
************************
************************      ls_changeset_response-operation_no = ls_changeset_request-operation_no.
************************
************************      CASE lv_entity_type.
************************        WHEN 'Remediate'.
************************          ls_changeset_request-entry_provider->read_entry_data( IMPORTING es_data = ls_item ).
************************
************************          obj_name = ls_item-objectname.
************************          ls_transport = ls_item-transport.
************************          ls_package = ls_item-package.
************************
************************          CALL METHOD l_ref->execute
************************            EXPORTING
************************              im_object      = obj_name
************************              im_transportno = ls_transport
************************              im_package     = ls_package
************************            IMPORTING
************************              ex_message     = DATA(lt_messages).
************************
************************
************************          IF lt_messages is NOT INITIAL.
************************
************************
************************          CALL METHOD l_ref->process_application_log
************************            EXPORTING
************************              im_object  = obj_name
************************              ex_message = lt_messages
************************              .
************************
************************          ENDIF.
************************
************************
**********************************
**********************************          ls_message-line = ''.
**********************************          ls_message-message = 'Error 1'.
**********************************          ls_message-typ = 'E'.
**********************************
**********************************          APPEND ls_message to lt_messages.
**********************************
**********************************           ls_message-line = ''.
**********************************          ls_message-message = 'Error 2'.
**********************************          ls_message-typ = 'E'.
**********************************
**********************************          APPEND ls_message to lt_messages.
**********************************
**********************************           ls_message-line = ''.
**********************************          ls_message-message = 'Error 3'.
**********************************          ls_message-typ = 'E'.
**********************************
**********************************          APPEND ls_message to lt_messages.
**********************************
**********************************           ls_message-line = ''.
**********************************          ls_message-message = 'Error 4'.
**********************************          ls_message-typ = 'E'.
**********************************
**********************************          APPEND ls_message to lt_messages.
************************
************************
************************
************************
*************************          refresh lt_messages.
*************************
*************************             CALL METHOD l_ref->execute
*************************            EXPORTING
*************************              im_object      = obj_name
*************************              im_transportno = ls_transport
*************************              im_package     = ls_package
*************************            IMPORTING
*************************              ex_message     = lt_messages.
************************
************************
************************
************************          READ TABLE lt_messages ASSIGNING FIELD-SYMBOL(<fs_messages>) WITH KEY typ = 'E'.
************************          IF sy-subrc EQ 0.
************************            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
************************              RECEIVING
************************                ro_message_container = lo_message_container.
************************            DATA : lv_mess TYPE string. "TYPE bapi_msg.
************************            lv_mess = <fs_messages>-message.
************************            lv_error = abap_true.
************************
************************            CONCATENATE lv_m ls_item-objectname INTO lv_m SEPARATED BY cl_abap_char_utilities=>cr_lf.
************************
************************            data:lv_msgid TYPE SYMSGID.
************************            LOOP AT lt_messages INTO DATA(ls_messages) where typ = 'E'.
************************              lv_mess = ls_messages-message.
************************              lv_message = ls_messages-message.
************************              lv_msgid = ls_item-objectname.
************************              lo_message_container->add_message(
************************                  EXPORTING
************************                    iv_msg_id = lv_msgid
************************                    iv_msg_number = '000'
************************                    iv_msg_type = ls_messages-typ
************************                    iv_msg_text = lv_message
************************                    iv_is_leading_message = abap_true
************************                    iv_add_to_response_header = abap_true
************************              ).
************************            ENDLOOP.
************************
************************            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
************************        EXPORTING
************************          textid            = /iwbep/cx_mgw_busi_exception=>business_error
************************          message_container = lo_message_container.
*************************            CALL METHOD lo_message_container->add_message
*************************              EXPORTING
*************************                iv_msg_type               = /iwbep/cl_cos_logger=>error
*************************                iv_msg_id                 = 'ZINVENTORY'
*************************                iv_msg_number             = '000'
*************************                iv_msg_text               = lv_mess
*************************                iv_add_to_response_header = abap_true.
*************************
*************************            ls_header-name = 'Response' .
************************
*************************            CONCATENATE: '{"Type": "' lc_e '","Message":"' lv_m '"}'
*************************            INTO ls_header-value.
*************************
*************************            /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
************************
**********************************            RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
**********************************              EXPORTING
**********************************                textid            = /iwbep/cx_mgw_busi_exception=>business_error
**********************************                message = lv_mess.
**********************************                message_container = lo_message_container.
************************
*************************                 message = 'subhashini'.
************************
************************
************************
************************
************************          ELSE.
************************
************************            copy_data_to_ref(
************************                        EXPORTING
************************                        is_data = ls_item
************************                        CHANGING
************************                        cr_data = ls_changeset_response-entity_data ).
************************
************************
************************
************************            INSERT ls_changeset_response INTO TABLE ct_changeset_response.
*************************            CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
*************************              RECEIVING
*************************                ro_message_container = lo_message_container.
*************************
*************************            CALL METHOD lo_message_container->add_message
*************************              EXPORTING
*************************                iv_msg_type               = /iwbep/cl_cos_logger=>success
*************************                iv_msg_id                 = 'ZTEST'
*************************                iv_msg_number             = '000'
*************************                iv_msg_text               = 'Remediation Successful testing'
*************************                iv_add_to_response_header = abap_true. "add the message to the header
*************************            ls_header-name = 'Response' .
*************************            CONCATENATE: '{"Type": "' lc_s '","Message":"Saved"}'
*************************            INTO ls_header-value.
*************************
*************************            /iwbep/if_mgw_conv_srv_runtime~set_header( ls_header ).
************************          ENDIF.
************************          refresh : lt_messages.
************************
************************      ENDCASE.
************************
************************    ENDLOOP.
************************    IF lv_error EQ abap_true.
***************************      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
***************************        EXPORTING
***************************          textid            = /iwbep/cx_mgw_busi_exception=>business_error
***************************          message_container = lo_message_container.
*************************          message_unlimited = lv_m.
************************    ENDIF.

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.


    DATA: BEGIN OF ls_order_item_data.
            INCLUDE TYPE zcl_zricefw_inv_mpc=>ts_header.
    DATA:   todeep TYPE zcl_zricefw_inv_mpc=>tt_remediate,
          END OF ls_order_item_data.

    TYPES:
      BEGIN OF ty_message,
        objectname TYPE sobj_name,
        line       TYPE i,
        typ        TYPE char1,
        message    TYPE string,
      END OF ty_message .

    DATA(lr_obj) = zcl_code_remediation=>get_instance( ).


    DATA: lt_message           TYPE TABLE OF ty_message,
          ls_message           LIKE LINE OF lt_message,
          l_ref                TYPE REF TO zcl_code_remediation,
          obj_name             TYPE sobj_name,
          ls_transport         TYPE trkorr,
          ls_package           TYPE devclass,
          lo_message_container TYPE REF TO /iwbep/if_message_container,
          lv_message           TYPE bapi_msg,
          ls_header            TYPE ihttpnvp,
          lv_m                 TYPE string,
          lt_remediate         TYPE TABLE OF zstr_code_remediation,
          ls_remediate         TYPE zstr_code_remediation,
          lv_line              TYPE i,
          lv_error             TYPE boolean VALUE abap_false.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_order_item_data ).





    LOOP AT ls_order_item_data-todeep ASSIGNING FIELD-SYMBOL(<fs_items>).

      ls_remediate-obj_name = <fs_items>-objectname.
      obj_name = <fs_items>-objectname.
      ls_remediate-line_no = <fs_items>-line.
      ls_package = <fs_items>-package.
      ls_transport = <fs_items>-transport.

*****      CALL METHOD me->execute
******        EXPORTING
******          im_object      =
******          im_objtyp      =
******          im_transportno =
******          im_package     =
******          im_runseries   =
******        IMPORTING
******          ex_message     =
*****          .
*****




***      IF lt_messages IS NOT INITIAL.
***
***        CALL METHOD lr_obj->process_application_log
***          EXPORTING
***            im_object  = obj_name
***            ex_message = lt_messages.
***
***      ENDIF.



      APPEND ls_remediate TO lt_remediate.

    ENDLOOP.


    CALL METHOD lr_obj->execute
      EXPORTING
        im_object        = obj_name
        im_transportno   = ls_transport
        im_package       = ls_package
        im_apply_changes = abap_true
        im_cnfrm_remed   = lt_remediate   "Table
      IMPORTING
        ex_message       = DATA(lt_messages).

    LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_processmessage>).


      MOVE-CORRESPONDING <fs_processmessage> TO ls_message.
      ls_message-objectname = obj_name.
*        ls_message-typ = 'E'.

      APPEND ls_message TO lt_message.
    ENDLOOP.

    REFRESH:lt_messages.
    CLEAR:ls_message.


    READ TABLE lt_message ASSIGNING FIELD-SYMBOL(<fs_messages>) WITH KEY typ = 'E'.
    IF sy-subrc EQ 0.
      CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~get_message_container
        RECEIVING
          ro_message_container = lo_message_container.
      DATA : lv_mess TYPE string. "TYPE bapi_msg.
      lv_mess = <fs_messages>-message.
      lv_error = abap_true.

      DATA:lv_msgid TYPE symsgid.
      LOOP AT lt_message INTO DATA(ls_messages) WHERE typ = 'E'.
*        lv_mess = ls_messages-message.
        lv_message = ls_messages-message.
        lv_msgid = ls_messages-objectname.
        lo_message_container->add_message(
            EXPORTING
              iv_msg_id = lv_msgid
              iv_msg_number = '000'
              iv_msg_type = ls_messages-typ
              iv_msg_text = lv_message
              iv_is_leading_message = abap_true
              iv_add_to_response_header = abap_true
        ).
      ENDLOOP.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message_container = lo_message_container.

    ELSE.

      copy_data_to_ref(
         EXPORTING
         is_data = ls_order_item_data
         CHANGING
         cr_data = er_deep_entity
         ).

    ENDIF.

  ENDMETHOD.


  method ATCDETAILSSET_GET_ENTITYSET.

   DATA: o_rep TYPE REF TO zcl_quality_scan,
         ls_entityset TYPE ZCL_ZRICEFW_INV_MPC=>TS_ATCDETAILS,
         lv_objectname TYPE SEOCLSNAME,
         lv_objecttype type TROBJTYPE.


    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter>) WITH KEY Property = 'ObjectName'.
    IF sy-subrc EQ 0.

      LOOP AT <ls_filter>-select_options ASSIGNING FIELD-SYMBOL(<ls_select_options>).
        lv_objectname = <ls_select_options>-low.
      ENDLOOP.

    ENDIF.

    lv_objecttype = 'CLAS'.

        o_rep = NEW #( ).

        select SINGLE * from tadir INTO @DATA(ls_obj) WHERE OBJ_NAME = @lv_objectname.


    o_rep->atc_check_details(
      EXPORTING
*                                   im_ricefw_id =
        im_obj_name = lv_objectname
        im_object_type = lv_objecttype
      IMPORTING
        ex_sci_detail   = DATA(lt_atc_details) ).


    IF not lt_atc_details IS INITIAL.

      LOOP AT lt_atc_details ASSIGNING FIELD-SYMBOL(<fs_atc_details>).

        ls_entityset-objectname = <fs_atc_details>-objname.
        ls_entityset-testparameter = <fs_atc_details>-test.
        ls_entityset-type = <fs_atc_details>-kind.
        ls_entityset-line = <fs_atc_details>-line.
        ls_entityset-column = <fs_atc_details>-col.
        ls_entityset-description = <fs_atc_details>-param3.
        ls_entityset-code = <fs_atc_details>-code.
        ls_entityset-author = <fs_atc_details>-ciuser.

        append ls_entityset to et_entityset.

      ENDLOOP.

    ENDIF.


  endmethod.


  METHOD befafterdetailss_get_entityset.

    DATA:ls_entityset TYPE zcl_zricefw_inv_mpc=>ts_befafterdetails.

    DATA : lv_objectname  TYPE sobj_name,
           lv_transportno TYPE trkorr,
           lv_package     TYPE devclass.



    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter>) WITH KEY property = 'Transport'.
    IF sy-subrc EQ 0.
      READ TABLE <ls_filter>-select_options ASSIGNING FIELD-SYMBOL(<ls_select_options>) INDEX 1.
      IF sy-subrc EQ 0.
        lv_transportno = <ls_select_options>-low.
      ENDIF.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter> WITH KEY property = 'ObjectName'.
    IF sy-subrc EQ 0.
      READ TABLE <ls_filter>-select_options ASSIGNING <ls_select_options> INDEX 1.
      IF sy-subrc EQ 0.
        lv_objectname = <ls_select_options>-low.
      ENDIF.
    ENDIF.

    READ TABLE it_filter_select_options ASSIGNING <ls_filter> WITH KEY property = 'Package'.
    IF sy-subrc EQ 0.
      READ TABLE <ls_filter>-select_options ASSIGNING <ls_select_options> INDEX 1.
      IF sy-subrc EQ 0.
        lv_package = <ls_select_options>-low.
      ENDIF.
    ENDIF.

    DATA(lr_obj) = zcl_code_remediation=>get_instance( ).

    CALL METHOD lr_obj->execute
      EXPORTING
        im_object        = lv_objectname
        im_transportno   = lv_transportno
        im_package       = lv_package
        im_apply_changes = abap_false
      IMPORTING
        ex_message       = DATA(lt_messages)
        ex_result        = DATA(lt_result).


    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result>).


      ls_entityset-codeafter = <ls_result>-after.
      ls_entityset-codebefore = <ls_result>-before.
      ls_entityset-lineno = <ls_result>-line_no.
      ls_entityset-objectname = <ls_result>-obj_name.
      ls_entityset-parentobj = <ls_result>-parent_obj.
      ls_entityset-remedtype = <ls_result>-remediation_type.

      APPEND ls_entityset TO et_entityset.

    ENDLOOP.

  ENDMETHOD.


  METHOD dependentobjects_get_entityset.
**TRY.
*CALL METHOD SUPER->DEPENDENTOBJECTS_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    io_tech_request_context  =
**  IMPORTING
**    et_entityset             =
**    es_response_context      =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
    DATA:lv_transport TYPE trkorr.

    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter>) WITH KEY Property = 'Transport'.
    IF sy-subrc EQ 0.

      LOOP AT <ls_filter>-select_options ASSIGNING FIELD-SYMBOL(<ls_select_options>).
        lv_transport = <ls_select_options>-low.
      ENDLOOP.

    ENDIF.


    DATA:lt_objects   TYPE TABLE OF ztransport_details,

         ls_entityset TYPE zcl_zricefw_inv_mpc=>Ts_DEPENDENTOBJECT.
    DATA: o_rep TYPE REF TO zcl_quality_scan.

    o_rep = NEW #( ).


    o_rep->get_dependent_objects(
      EXPORTING
*                                   im_ricefw_id =
        im_transport = lv_transport
      IMPORTING
        ex_objects   = lt_objects ).
    .


    LOOP AT lt_objects ASSIGNING FIELD-SYMBOL(<ls_objects>).

      ls_entityset-objectname = <ls_objects>-obj_name.
      ls_entityset-objectdesc = <ls_objects>-obj_text.
      ls_entityset-author = <ls_objects>-as4user.

      APPEND ls_entityset TO et_entityset.

    ENDLOOP.





  ENDMETHOD.


  METHOD joblogset_get_entityset.

    DATA:lt_header      TYPE TABLE OF balhdr,
         lt_header_par  TYPE TABLE OF balhdrp,
         lt_messages    TYPE TABLE OF balm,
         lt_message_par TYPE TABLE OF balmp,
         ls_addr        TYPE bapiaddr3,
         lt_return      TYPE TABLE OF bapiret2,
         lv_uname       TYPE sy-uname,
         lv_n           TYPE i,
         ls_entityset   TYPE zcl_zricefw_inv_mpc=>Ts_JOBLOG,
         lt_exceptions  TYPE TABLE OF bal_s_exception.


    CALL FUNCTION 'APPL_LOG_READ_DB'
      EXPORTING
        object             = 'ZREMEDIATION'
        subobject          = '*'
        external_number    = ' '
        date_from          = '00000000'
        date_to            = sy-datum
        time_from          = '000000'
        time_to            = sy-uzeit
        log_class          = '4'
        program_name       = '*'
        transaction_code   = '*'
        user_id            = ' '
        mode               = '+'
        put_into_memory    = ' '
      IMPORTING
        number_of_logs     = lv_n
      TABLES
        header_data        = lt_header
        header_parameters  = lt_header_par
        messages           = lt_messages
        message_parameters = lt_message_par
*       CONTEXTS           =
        t_exceptions       = lt_exceptions.



    .


    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).

      LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<fs_messages>) WHERE lognumber = <fs_header>-lognumber.

*        IF sy-subrc EQ 0.

          ls_entityset-message = <fs_messages>-msgv1.
          CONCATENATE <fs_messages>-msgv1 <fs_messages>-msgv2 INTO ls_entityset-message SEPARATED BY space.
          ls_entityset-programname = <fs_header>-extnumber.
          ls_entityset-type = <fs_messages>-msgty.
          ls_entityset-createdby  = <fs_header>-aluser.
          ls_entityset-createdon = <fs_header>-aldate.

          IF <fs_header>-aluser IS NOT INITIAL.
            lv_uname = <fs_header>-aluser.
            CALL FUNCTION 'BAPI_USER_GET_DETAIL'
              EXPORTING
                username = lv_uname
              IMPORTING
                address  = ls_addr
              TABLES
                return   = lt_return.
            ls_entityset-createdby =  |{ ls_addr-firstname } { ls_addr-lastname }|.
          ENDIF.


          APPEND ls_entityset TO et_entityset.

*        ENDIF.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.


  method PACKAGELISTSET_GET_ENTITYSET.



data:ls_entityset type ZCL_ZRICEFW_INV_MPC=>TS_PACKAGELIST.

SELECT * from ZTUTL_CNTROL into TABLE @data(lt_packages).

  LOOP AT lt_packages ASSIGNING FIELD-SYMBOL(<fs_packages>).

    ls_entityset-package = <fs_packages>-devclass.
    ls_entityset-description = <fs_packages>-ctext.

    APPEND ls_entityset to et_entityset.

  ENDLOOP.


  endmethod.


  method REMEDIATESET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->REMEDIATESET_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.


  endmethod.


  method REMEDIATESET_GET_ENTITY.
**TRY.
*CALL METHOD SUPER->REMEDIATESET_GET_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_request_object       =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**  IMPORTING
**    er_entity               =
**    es_response_context     =
*    .
**  CATCH /iwbep/cx_mgw_busi_exception.
**  CATCH /iwbep/cx_mgw_tech_exception.
**ENDTRY.
  endmethod.


  METHOD ricefwlistset_get_entityset.

*    TABLES trdir.

********    TYPES: BEGIN OF seop_method_w_include,
********             cpdkey  TYPE seocpdkey,
********             incname TYPE programm,
********           END OF seop_method_w_include,
********
********           BEGIN OF ty_output,
********             program     TYPE char30,
********             author      TYPE char30,
********             transport   TYPE char10,
********             create_date TYPE char10,
********             objid       TYPE char30,
********             description TYPE char60,
********           END OF ty_output,
********
********           BEGIN OF ty_pgnames,
********             Pgname TYPE trdir-name,
********           END OF ty_pgnames.
********
********
********    DATA:lt_pgnames TYPE TABLE OF ty_pgnames,
********         ls_pgname  TYPE ty_pgnames.
********
********
********
********    DATA: lt_cl_include TYPE STANDARD TABLE OF seop_method_w_include.
********
********
********    DATA: lt_source      TYPE string_table,
********          ls_fun_include TYPE rs38l-include,
********          lv_class_name  TYPE seoclsname,
********          lv_prog_name   TYPE trdir-name,
********          ls_output      TYPE ty_output,
********          ls_entityset type  ZCL_ZRICEFW_INV_MPC=>Ts_RICEFWLIST,
********          lt_output      TYPE STANDARD TABLE OF ty_output.
********
********
********
*********    SELECT SINGLE * FROM trdir INTO CORRESPONDING FIELDS OF trdir
*********      WHERE name EQ p_pgname.
*********    IF sy-subrc = 0.
*********      lv_prog_name = p_pgname.
*********    ENDIF.
********
********
********
********    ls_pgname = 'ZREAD_PROGRAM_LINE'.
********    APPEND ls_pgname TO lt_pgnames.
********
********    ls_pgname = 'ZREAD_PROGRAM_LINE1'.
********    APPEND ls_pgname TO lt_pgnames.
********
********    ls_pgname = 'ZREAD_PROGRAM_LINE2'.
********    APPEND ls_pgname TO lt_pgnames.
********
********    LOOP AT lt_pgnames ASSIGNING FIELD-SYMBOL(<fs_pgnames>).
********
********      lv_prog_name = <fs_pgnames>-pgname.
********
********      READ REPORT lv_prog_name STATE 'A' INTO lt_source.
********
********      LOOP AT lt_source INTO DATA(ls_source).
********
********        IF ls_source+0(1) NE '*'.
********          EXIT.
********        ENDIF.
********
********        IF ls_source CS 'PROGRAM ID'.
********          SPLIT ls_source AT ':' INTO DATA(lv_dummy) DATA(lv_data).
********          IF sy-subrc = 0.
********            ls_output-program = lv_data.
********          ENDIF.
********        ELSEIF ls_source CS 'AUTHOR'.
********
********          SPLIT ls_source AT ':' INTO lv_dummy lv_data.
********          IF sy-subrc = 0.
********            ls_output-author = lv_data.
********          ENDIF.
********        ELSEIF ls_source CS 'TR DETAILS'.
********          SPLIT ls_source AT ':' INTO lv_dummy lv_data.
********          IF sy-subrc = 0.
********            ls_output-transport = lv_data.
********          ENDIF.
********
********        ELSEIF ls_source CS 'CREATE DATE'.
********          SPLIT ls_source AT ':' INTO lv_dummy lv_data.
********          IF sy-subrc = 0.
********            ls_output-create_date = lv_data.
********          ENDIF.
********        ELSEIF ls_source CS 'OBJECT ID'.
********          SPLIT ls_source AT ':' INTO lv_dummy lv_data.
********          IF sy-subrc = 0.
********            ls_output-objid = lv_data.
********          ENDIF.
********        ELSEIF ls_source CS 'DESCRIPTION'.
********          SPLIT ls_source AT ':' INTO lv_dummy lv_data.
********          IF sy-subrc = 0.
********            DATA(lv_length) = strlen( lv_data ) - 1.
********
********            ls_output-description = lv_data+0(lv_length).
********          ENDIF.
********        ENDIF.
********
*********   UPDATE lt_output FROM ls_output .
********
********      ENDLOOP.
********
********      ls_entityset-author = ls_output-author.
*********      ls_entityset-creationdate = ls_output-create_date.
********
********      CONCATENATE ls_output-create_date+6(4)  ls_output-create_date+0(2) ls_output-create_date+3(2) INTO ls_entityset-creationdate.
********      ls_entityset-objectdescription = ls_output-description.
********      ls_entityset-objectname = ls_output-program.
********      ls_entityset-transports = ls_output-transport.
********
********      APPEND ls_entityset to et_entityset.
********
********
********    clear: lv_prog_name, ls_output, ls_source.
********
********    refresh : lt_source.
********
********    ENDLOOP.

    TYPES:BEGIN OF ty_atc,
            prg_name TYPE sobj_name,
            error    TYPE char4,
            warning  TYPE char4,
            info     TYPE char4,
          END OF ty_atc.





    DATA: lt_objects     TYPE /sdf/tadir_tt,
          ls_obj_struct  TYPE zobj_include,
          lv_tot_error   TYPE char4,
          lv_information TYPE char4,
          lv_error       TYPE char4,
          lv_warning     TYPE char4,
          lt_atc         TYPE TABLE OF ty_atc,
          ls_atc         LIKE LINE OF lt_Atc,
          lv_package type DEVCLASS,
          ls_entityset   TYPE  zcl_zricefw_inv_mpc=>Ts_RICEFWLIST.


    DATA: o_rep TYPE REF TO zcl_quality_scan.

    o_rep = NEW #( ).

    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter>) WITH KEY Property = 'Package'.
    IF sy-subrc EQ 0.

      LOOP AT <ls_filter>-select_options ASSIGNING FIELD-SYMBOL(<ls_select_options>).
        lv_package = <ls_select_options>-low.
      ENDLOOP.

    ENDIF.


    o_rep->get_custom_program(
  EXPORTING
*    im_object_type  =                  " Object Type
*    im_object_name  =                  " Object Name in Object Directory
    im_package      =                  lv_package
      IMPORTING
        ex_objects      =  lt_objects               " Directory of Repository Objects
      EXCEPTIONS
        no_record_found = 1                " No records found
        OTHERS          = 2
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA: lt_include TYPE zobj_include_tt.

    o_rep->get_include_name(
      EXPORTING
        im_objects      = lt_objects                 " TADIR table type
      IMPORTING
        ex_include      =   lt_include               " Include program details
      EXCEPTIONS
        no_record_found = 1                " No records found
        OTHERS          = 2
    ).
    IF sy-subrc <> 0.

    ENDIF.

******    IF lt_include IS NOT INITIAL.
******
******      LOOP AT lt_include ASSIGNING FIELD-SYMBOL(<fs_objects>) from 1 to 5.
******
**********        ls_obj_struct-obj_name   = <fs_objects>-obj_name.
**********        ls_obj_struct-object_type  = <fs_objects>-object.
**********        ls_obj_struct-pgmid   = <fs_objects>-pgmid.
**********        ls_obj_struct-include = <fs_objects>-obj_name.
******
******        o_rep->atc_check_details(
******          EXPORTING
******            im_include     = <fs_objects>
******          IMPORTING
******            ex_tot_error   = lv_tot_error
******            ex_information = lv_information
******            ex_error       = lv_error
******            ex_warning     = lv_warning
******            ).
******
******        ls_atc-prg_name = <fs_objects>-obj_name.
******        ls_atc-error = lv_error.
******        ls_atc-warning = lv_warning.
******        ls_atc-info = lv_information.
******
******        APPEND ls_atc TO lt_atc.
******        CLEAR:lv_information,lv_error,lv_warning,ls_atc,ls_obj_struct.
******
******      ENDLOOP.


*******    ENDIF.

    SORT lt_include BY obj_name.

    DELETE ADJACENT DUPLICATES FROM lt_include COMPARING obj_name.

    DATA lt_header TYPE zheader_det_tt.

    o_rep->get_header_detail(
      EXPORTING
        im_include    = lt_include     " Include program details
      IMPORTING
        ex_header_det = lt_header
        ex_atc_count  = data(lt_atc_count)     " Header Details of Program
    ).



    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).

      ls_entityset-author = <ls_header>-created_by.
      ls_entityset-creationdate = <ls_header>-erdat.

*
*      CONCATENATE ls_output-create_date+6(4)  ls_output-create_date+0(2) ls_output-create_date+3(2) INTO ls_entityset-creationdate.
      ls_entityset-objectdescription = <ls_header>-description.
      ls_entityset-objectname = <ls_header>-obj_name-clsname.
      ls_entityset-lastmodifieddate = <ls_header>-erdat.
       ls_entityset-system = 'E2T'.


****      if sy-tabix le 4.
****      ls_entityset-information = 22.
****      ENDIF.
****      if sy-tabix gt 4 and sy-tabix lt 56.
****      ls_entityset-Warnings = 20.
****      endif.
****      if sy-tabix gt 46 and sy-tabix lt 95.
****      ls_entityset-Errors = 13.
****      ENDIF.
      READ TABLE lt_atc_count ASSIGNING FIELD-SYMBOL(<fs_atc_count>) WITH KEY CLSNAME = <ls_header>-obj_name-clsname.
      IF sy-subrc EQ 0.

        ls_entityset-information = <fs_atc_count>-info.
        IF <fs_atc_count>-info > 0.
          ls_entityset-infoflag = abap_true.
        ENDIF.
        ls_entityset-Warnings = <fs_atc_count>-warning.
           IF <fs_atc_count>-warning > 0.
          ls_entityset-warningflag = abap_true.
        ENDIF.
        ls_entityset-Errors = <fs_atc_count>-error.
          IF <fs_atc_count>-error > 0.
          ls_entityset-errorflag = abap_true.
        ENDIF.

      ENDIF.

*    ls_entityset-transports = <ls_header>-.

      DATA(lt_transports) = <ls_header>-transport.

      LOOP AT lt_transports ASSIGNING FIELD-SYMBOL(<fs_transports>).


        ls_entityset-transports =  <fs_transports>-korrnum.

      ENDLOOP.

      APPEND ls_entityset TO et_entityset.

      REFRESH lt_transports.

      CLEAR ls_entityset.

    ENDLOOP.


***************** ls_entityset-author = 'Sudarshan'.
*****************   ls_entityset-creationdate = Sy-datum.
******************
******************      CONCATENATE ls_output-create_date+6(4)  ls_output-create_date+0(2) ls_output-create_date+3(2) INTO ls_entityset-creationdate.
*****************      ls_entityset-objectdescription = 'test1'.
*****************      ls_entityset-objectname = 'Object1'.
*****************      ls_entityset-transports =  'EK90837837'.
*****************      ls_entityset-lastmodifieddate = sy-datum.
*****************      ls_entityset-information = 12.
*****************      ls_entityset-Warnings = 21.
*****************      ls_entityset-Errors = 15.
*****************
*****************
*****************
*****************      APPEND ls_entityset TO et_entityset.
*****************
*****************       ls_entityset-author = 'Anish'.
*****************   ls_entityset-creationdate = sy-datum + 1.
******************
******************      CONCATENATE ls_output-create_date+6(4)  ls_output-create_date+0(2) ls_output-create_date+3(2) INTO ls_entityset-creationdate.
*****************      ls_entityset-objectdescription = 'test2'.
*****************      ls_entityset-objectname = 'Object2'.
*****************       ls_entityset-transports =  'EK90837838'.
*****************      ls_entityset-lastmodifieddate = sy-datum + 2.
*****************       ls_entityset-information = 22.
*****************      ls_entityset-Warnings = 20.
*****************      ls_entityset-Errors = 13.
*****************
*****************APPEND ls_entityset TO et_entityset.


  ENDMETHOD.


  METHOD transportlistset_get_entityset.

    DATA:lv_objectname TYPE string,
         ls_entityset  TYPE zcl_zricefw_inv_mpc=>Ts_TRANSPORTLIST.
    DATA: o_rep TYPE REF TO zcl_quality_scan.
    READ TABLE it_filter_select_options ASSIGNING FIELD-SYMBOL(<ls_filter>) WITH KEY Property = 'ObjectName'.
    IF sy-subrc EQ 0.

      LOOP AT <ls_filter>-select_options ASSIGNING FIELD-SYMBOL(<ls_select_options>).
        lv_objectname = <ls_select_options>-low.
      ENDLOOP.

    ENDIF.


    o_rep = NEW #( ).


    o_rep->get_transport_detail(
      EXPORTING
*                                   im_ricefw_id =
        im_object = lv_objectname
      IMPORTING
        ex_transportlist   = DATA(lt_transportlist) ).


    LOOP AT lt_transportlist ASSIGNING FIELD-SYMBOL(<fs_transportlist>).

      ls_entityset-objectname = <fs_transportlist>-obj_name.
      ls_entityset-transportno = <fs_transportlist>-trkorr.
      ls_entityset-description = <fs_transportlist>-tr_desc.
      ls_entityset-createdon = <fs_transportlist>-as4date.
**      ls_entityset-changedon = <fs_transportlist>-as4date.
      ls_entityset-author = <fs_transportlist>-as4user.

      APPEND ls_entityset TO et_entityset.

    ENDLOOP.






  ENDMETHOD.
ENDCLASS.
