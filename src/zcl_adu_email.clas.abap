"! <p class="shorttext synchronized" lang="en">Email utilities</p>
CLASS zcl_adu_email DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_adu_email.

    CLASS-METHODS get_instance
      RETURNING
        VALUE(result) TYPE REF TO zif_adu_email.

  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS send_email
      IMPORTING
        text          TYPE soli_tab
        subject       TYPE so_obj_des
        recipients    TYPE bcsy_smtpa
        attachments   TYPE zif_adu_email=>tt_attachment
        document_type TYPE so_obj_tp DEFAULT zif_adu_email=>document_type-raw
        commit_work   TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result) TYPE abap_bool
      RAISING
        cx_send_req_bcs
        cx_address_bcs
        cx_document_bcs.

ENDCLASS.



CLASS zcl_adu_email IMPLEMENTATION.


  METHOD get_instance.
    result = NEW zcl_adu_email( ).
  ENDMETHOD.


  METHOD zif_adu_email~send_email.

    result = send_email( text          = text
                         subject       = subject
                         recipients    = recipients
                         attachments   = attachments
                         document_type = document_type
                         commit_work   = commit_work ).

  ENDMETHOD.


  METHOD send_email.

    DATA(lo_send_request) = cl_bcs=>create_persistent( ).

    DATA(lo_sender) = cl_sapuser_bcs=>create( sy-uname ).

    lo_send_request->set_sender( lo_sender ).

    LOOP AT recipients REFERENCE INTO DATA(lr_recipement).

      DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address( lr_recipement->* ).

      lo_send_request->add_recipient( i_recipient = lo_recipient
                                      i_express   = abap_true ).

    ENDLOOP.

    DATA(lo_document) = cl_document_bcs=>create_document( i_type    = document_type
                                                          i_text    = text
                                                          i_subject = subject ).

    LOOP AT attachments REFERENCE INTO DATA(lr_attachment).
      lo_document->add_attachment( i_attachment_type    = lr_attachment->type
                                   i_attachment_subject = lr_attachment->subject
                                   i_attachment_size    = lr_attachment->size
                                   i_att_content_hex    = lr_attachment->content_hex ).
    ENDLOOP.

    lo_send_request->set_document( lo_document ).

    result = lo_send_request->send( abap_true ).

    IF result = abap_true AND commit_work = abap_true.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
