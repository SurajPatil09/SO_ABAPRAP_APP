CLASS lhc_sale DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR sale RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR sale RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE sale.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE sale.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE sale.

    METHODS read FOR READ
      IMPORTING keys FOR READ sale RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK sale.

    METHODS rba_Extra FOR READ
      IMPORTING keys_rba FOR READ sale\_Extra FULL result_requested RESULT result LINK association_links.

    METHODS rba_Item FOR READ
      IMPORTING keys_rba FOR READ sale\_Item FULL result_requested RESULT result LINK association_links.

    METHODS cba_Extra FOR MODIFY
      IMPORTING entities_cba FOR CREATE sale\_Extra.

    METHODS cba_Item FOR MODIFY
      IMPORTING entities_cba FOR CREATE sale\_Item.

    METHODS Approve FOR MODIFY
      IMPORTING keys FOR ACTION sale~Approve RESULT result.

    METHODS Reject FOR MODIFY
      IMPORTING keys FOR ACTION sale~Reject RESULT result.

ENDCLASS.

CLASS lhc_sale IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

  DATA: lt_create_data TYPE TABLE OF zsh_431,
        lv_max_so_id   TYPE zsh_431-so_id,
        lv_new_so_id   TYPE zsh_431-so_id,
        lv_timestamp   TYPE timestamp.

  " Field symbols to hold individual entries dynamically
  FIELD-SYMBOLS:  <fs_create_data> TYPE zsh_431.

  " Get current date and time
  GET TIME STAMP FIELD lv_timestamp.

  " Fetch the maximum so_id value from the table
  SELECT MAX( so_id ) FROM zsh_431 INTO @lv_max_so_id.

  " If no records are found, initialize to 0
  IF sy-subrc <> 0 OR lv_max_so_id IS INITIAL.
    lv_max_so_id = 0.
  ENDIF.

  " Loop through the entities parameter to extract data
  LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>) .
    " Increment the max so_id by 1 for the new entry
    lv_new_so_id = lv_max_so_id + 1.
    lv_max_so_id = lv_new_so_id. " Update max so_id for the next iteration

    " Create a new entry
    APPEND INITIAL LINE TO lt_create_data ASSIGNING <fs_create_data>.

    " Map the entity fields to the table fields
    <fs_create_data>-so_id = lv_new_so_id.
    <fs_create_data>-customer_id = <fs_entity>-CustomerId.
    <fs_create_data>-customer_desc = <fs_entity>-CustomerDesc.
    <fs_create_data>-so_date = <fs_entity>-SoDate.
    <fs_create_data>-salestatus = <fs_entity>-Salestatus.
    <fs_create_data>-local_last_changed_at = lv_timestamp.
  ENDLOOP.

  " Insert the data into the persistent table
  INSERT zsh_431 FROM TABLE @lt_create_data.

  " Check if the insert was successful and handle any errors
  IF sy-subrc <> 0.
    " Handle the error case
    "RAISE EXCEPTION TYPE cx_abap_insert_failed.
  ENDIF.

  " Loop through the created data to populate the 'mapped' structure
  LOOP AT lt_create_data ASSIGNING <fs_create_data>.
    " Find the corresponding entity for the current created data
    LOOP AT entities ASSIGNING <fs_entity> WHERE SoDate = <fs_create_data>-so_date.
      APPEND VALUE #( %cid = <fs_entity>-%cid
                      SoId = <fs_create_data>-so_id ) TO mapped-sale.
      EXIT.
    ENDLOOP.
  ENDLOOP.

  ENDMETHOD.

  METHOD update.

     DATA: lv_timestamp TYPE timestamp.

  " Field symbols to dynamically reference the data
  FIELD-SYMBOLS: <fs_update_data> TYPE zsh_431.

  " Get current date and time
  GET TIME STAMP FIELD lv_timestamp.

  " Loop through the entities parameter to extract the data
  LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entity>).
    " Read the current entry from the database
    SELECT SINGLE * FROM zsh_431
      WHERE so_id = @<fs_entity>-SoId
      INTO @DATA(ls_update_data).

    " Check if the entry exists
    IF sy-subrc = 0.
      " Assign the selected data to a field symbol
      ASSIGN ls_update_data TO <fs_update_data>.

      " Update only the changed fields
      IF <fs_entity>-CustomerId IS NOT INITIAL.
        <fs_update_data>-customer_id = <fs_entity>-CustomerId.
      ENDIF.
      IF <fs_entity>-CustomerDesc IS NOT INITIAL.
        <fs_update_data>-customer_desc = <fs_entity>-CustomerDesc.
      ENDIF.
      IF <fs_entity>-SoDate IS NOT INITIAL.
        <fs_update_data>-so_date = <fs_entity>-SoDate.
      ENDIF.
      IF <fs_entity>-Salestatus IS NOT INITIAL.
        <fs_update_data>-salestatus = <fs_entity>-Salestatus.
      ENDIF.
      " Update the entry in the persistent table
      UPDATE zsh_431 SET
        customer_id = @<fs_update_data>-customer_id,
        customer_desc = @<fs_update_data>-customer_desc,
        so_date = @<fs_update_data>-so_date,
        salestatus        = @<fs_update_data>-salestatus,
        local_last_changed_at = @lv_timestamp
      WHERE so_id = @<fs_update_data>-so_id.

      " Check if the update was successful and handle any errors
      IF sy-subrc <> 0.
        " Handle the error case
        " RAISE EXCEPTION TYPE cx_abap_update_failed.
      ENDIF.
    ELSE.
      " Handle the case where the entry does not exist
      " RAISE EXCEPTION TYPE cx_abap_update_failed.
    ENDIF.
  ENDLOOP.

  ENDMETHOD.

  METHOD delete.

   " Define a work area to hold the key of the entry to be deleted
    "DATA: ls_delete_key TYPE zsh_431.

    " Loop through the keys parameter to extract the keys
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>). "INTO DATA(ls_key).
      " Map the key fields to the work area
      "  ls_delete_key-so_id = ls_key-so_id.

      " Delete the entry from the persistent table
      DELETE FROM zsh_431 WHERE so_id = @<fs_key>-SoId. "@ls_delete_key-so_id.

      IF sy-subrc <> 0.
        " Handle the error case
        "RAISE EXCEPTION TYPE cx_abap_delete_failed.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

    DATA lt_sales_data TYPE TABLE OF zsh_431.

    " Check if specific keys are requested
    IF keys IS NOT INITIAL.
      " Fetch data for specified keys
      SELECT * FROM zsh_431
        FOR ALL ENTRIES IN @keys
        WHERE so_id = @keys-SoId
        INTO TABLE @lt_sales_data.
    ELSE.
      " Fetch all data if no specific keys are provided
      SELECT * FROM zsh_431
        INTO TABLE @lt_sales_data.
    ENDIF.

    " Assign fetched data to result
    result = CORRESPONDING #( lt_sales_data MAPPING TO ENTITY ).

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Extra.
  ENDMETHOD.

  METHOD rba_Item.
  ENDMETHOD.

  METHOD cba_Extra.

    DATA: lt_create_data TYPE TABLE OF zse_431,
        lt_so_id       TYPE TABLE OF zse_431-so_id,
        lv_max_extra_id   TYPE zse_431-extra_id,
        lv_new_extra_id  TYPE zse_431-extra_id.

  FIELD-SYMBOLS: <fs_create_data> TYPE zse_431.

  " Extract so_id values from entities
  LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_entity>).
    APPEND <fs_entity>-SoId TO lt_so_id.
  ENDLOOP.

  " Remove duplicate so_id entries
  DELETE ADJACENT DUPLICATES FROM lt_so_id.

  " Process each so_id
  LOOP AT lt_so_id INTO DATA(lv_so_id).
    " Fetch the maximum item_id for the so_id
    SELECT MAX( extra_id ) FROM zse_431 WHERE so_id = @lv_so_id INTO @lv_max_extra_id.
    IF sy-subrc <> 0.
      lv_max_extra_id = 0. " Default if no entries found
    ENDIF.

    " Process entries for this so_id
    LOOP AT entities_cba ASSIGNING <fs_entity> WHERE SoId = lv_so_id.
      " Initialize a new entry for lt_create_data
      APPEND INITIAL LINE TO lt_create_data ASSIGNING <fs_create_data>.

      " Calculate the new item_id
      lv_new_extra_id = lv_max_extra_id + 1.
      lv_max_extra_id = lv_new_extra_id. " Update for next iteration

      " Copy data from entity to the new structure entry
      <fs_create_data>-extra_id = lv_new_extra_id.
      <fs_create_data>-so_id = <fs_entity>-SoId.

      LOOP AT <fs_entity>-%target INTO DATA(convert).
        <fs_create_data>-comments = convert-Comments.
        <fs_create_data>-warehouse_id = convert-WarehouseId.
        <fs_create_data>-warehouse_address = convert-WarehouseAddress.
        <fs_create_data>-qty = convert-Qty.
         <fs_create_data>-unit = convert-Unit.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  " Insert data into the database
  INSERT zse_431 FROM TABLE @lt_create_data.

  " Error handling for database operation
  IF sy-subrc <> 0.
    "RAISE EXCEPTION TYPE cx_abap_insert_failed.
  ENDIF.


  ENDMETHOD.

  METHOD cba_Item.
   DATA: lt_create_data TYPE TABLE OF zsi_431,
        lt_so_id       TYPE TABLE OF zsi_431-so_id,
        lv_max_item_id   TYPE zsi_431-item_id,
        lv_new_item_id   TYPE zsi_431-item_id.

  FIELD-SYMBOLS: <fs_create_data> TYPE zsi_431.

  " Extract so_id values from entities
  LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_entity>).
    APPEND <fs_entity>-SoId TO lt_so_id.
  ENDLOOP.

  " Remove duplicate so_id entries
  DELETE ADJACENT DUPLICATES FROM lt_so_id.

  " Process each so_id
  LOOP AT lt_so_id INTO DATA(lv_so_id).
    " Fetch the maximum item_id for the so_id
    SELECT MAX( item_id ) FROM zsi_431 WHERE so_id = @lv_so_id INTO @lv_max_item_id.
    IF sy-subrc <> 0.
      lv_max_item_id = 0. " Default if no entries found
    ENDIF.

    " Process entries for this so_id
    LOOP AT entities_cba ASSIGNING <fs_entity> WHERE SoId = lv_so_id.
      " Initialize a new entry for lt_create_data
      APPEND INITIAL LINE TO lt_create_data ASSIGNING <fs_create_data>.

      " Calculate the new item_id
      lv_new_item_id = lv_max_item_id + 1.
      lv_max_item_id = lv_new_item_id. " Update for next iteration

      " Copy data from entity to the new structure entry
      <fs_create_data>-item_id = lv_new_item_id.
      <fs_create_data>-so_id = <fs_entity>-SoId.

      LOOP AT <fs_entity>-%target INTO DATA(convert).
        <fs_create_data>-material_no = convert-MaterialNo.
        <fs_create_data>-material_desc = convert-MaterialDesc.
        <fs_create_data>-amount = convert-Amount.
        <fs_create_data>-currency_code = convert-CurrencyCode.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  " Insert data into the database
  INSERT zsi_431 FROM TABLE @lt_create_data.

  " Error handling for database operation
  IF sy-subrc <> 0.
    "RAISE EXCEPTION TYPE cx_abap_insert_failed.
  ENDIF.
  ENDMETHOD.

  METHOD Approve.
   " Set the new overall status
    MODIFY ENTITIES OF zish_431 IN LOCAL MODE
      ENTITY sale
         UPDATE
           FIELDS ( Salestatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             saleStatus = 'Approve' ) )
      FAILED failed
      REPORTED reported.

    "get updated response record
    READ ENTITIES OF zish_431 IN LOCAL MODE
      ENTITY sale
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(zsales).

    result = VALUE #( FOR sale IN zsales
                        ( %tky   = sale-%tky
                          %param = sale ) ).

  ENDMETHOD.

  METHOD Reject.

    " Set the new overall status
    MODIFY ENTITIES OF zish_431 IN LOCAL MODE
      ENTITY sale
         UPDATE
           FIELDS ( Salestatus )
           WITH VALUE #( FOR key IN keys
                           ( %tky         = key-%tky
                             saleStatus = 'Reject' ) )
     FAILED failed
      REPORTED reported.

    " Fill the response table
    READ ENTITIES OF zish_431 IN LOCAL MODE
      ENTITY sale
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(sales).

    result = VALUE #( FOR sale IN sales
                        ( %tky   = sale-%tky
                          %param = sale ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE item.

    METHODS read FOR READ
      IMPORTING keys FOR READ item RESULT result.

    METHODS rba_Sale FOR READ
      IMPORTING keys_rba FOR READ item\_Sale FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD update.

  FIELD-SYMBOLS: <ls_update_data> TYPE zsi_431.

  " Loop through the entities parameter to extract the data
  LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
    DATA: ls_work_area TYPE zsi_431.

    " Read the current entry from the database
    SELECT SINGLE * FROM zsi_431
      WHERE so_id = @<ls_entity>-SoId
        AND item_id = @<ls_entity>-ItemId
        INTO @ls_work_area.

    " Check if the entry exists
    IF sy-subrc = 0.
      " Assign the work area to the field symbol
      ASSIGN ls_work_area TO <ls_update_data>.

      " Update only the changed fields
      IF <ls_entity>-MaterialNo IS NOT INITIAL.
        <ls_update_data>-material_no = <ls_entity>-MaterialNo.
      ENDIF.
      IF <ls_entity>-MaterialDesc IS NOT INITIAL.
        <ls_update_data>-material_desc = <ls_entity>-MaterialDesc.
      ENDIF.
      IF <ls_entity>-Amount IS NOT INITIAL.
        <ls_update_data>-amount = <ls_entity>-Amount.
      ENDIF.
      IF <ls_entity>-CurrencyCode IS NOT INITIAL.
        <ls_update_data>-currency_code = <ls_entity>-CurrencyCode.
      ENDIF.

      " Update the entry in the persistent table
      UPDATE zsi_431 SET
        material_no = @<ls_update_data>-material_no,
        material_desc = @<ls_update_data>-material_desc,
        amount = @<ls_update_data>-amount,
        currency_code = @<ls_update_data>-currency_code,
        lastchange = @<ls_update_data>-lastchange
      WHERE so_id = @<ls_update_data>-so_id
        AND item_id = @<ls_update_data>-item_id.

      " Check if the update was successful and handle any errors
      IF sy-subrc <> 0.
        " Handle the error case
        "RAISE EXCEPTION TYPE cx_abap_update_failed.
      ENDIF.
    ELSE.
      " Handle the case where the entry does not exist
      "RAISE EXCEPTION TYPE cx_abap_update_failed.
    ENDIF.
  ENDLOOP.

  ENDMETHOD.

  METHOD delete.

      " Define a work area to hold the key of the entry to be deleted
    "DATA: ls_delete_key TYPE zsi_431.

    " Loop through the keys parameter to extract the keys
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>). "INTO DATA(ls_key).
      " Map the key fields to the work area
     " ls_delete_key-so_id = ls_key-so_id.
      "ls_delete_key-item_id = ls_key-item_id.  " Ensure the item number is also mapped

      " Delete the entry from the persistent table
      DELETE FROM zsi_431 WHERE so_id = @<fs_key>-SoId AND item_id = @<fs_key>-ItemId .

      " Check if the delete was successful and handle any errors
      IF sy-subrc <> 0.
        " Handle the error case
        "RAISE EXCEPTION TYPE cx_abap_delete_failed.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

   SELECT * FROM  zsi_431 FOR ALL ENTRIES IN @keys
      WHERE so_id  = @keys-SoId
      INTO TABLE @DATA(lt_item_data).

    result = CORRESPONDING #( lt_item_data MAPPING TO ENTITY ).

  ENDMETHOD.

  METHOD rba_Sale.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_extra DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE extra.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE extra.

    METHODS read FOR READ
      IMPORTING keys FOR READ extra RESULT result.

    METHODS rba_Sale FOR READ
      IMPORTING keys_rba FOR READ extra\_Sale FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_extra IMPLEMENTATION.

  METHOD update.
  FIELD-SYMBOLS: <ls_update_data> TYPE zse_431.

  " Loop through the entities parameter to extract the data
  LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
    DATA: ls_work_area TYPE zse_431.

    " Read the current entry from the database
    SELECT SINGLE * FROM zse_431
      WHERE so_id = @<ls_entity>-SoId
        AND extra_id = @<ls_entity>-ExtraId
        INTO @ls_work_area.

    " Check if the entry exists
    IF sy-subrc = 0.
      " Assign the work area to the field symbol
      ASSIGN ls_work_area TO <ls_update_data>.

      " Update only the changed fields
      IF <ls_entity>-WarehouseId IS NOT INITIAL.
        <ls_update_data>-warehouse_id = <ls_entity>-WarehouseId.
      ENDIF.
      IF <ls_entity>-WarehouseAddress IS NOT INITIAL.
        <ls_update_data>-warehouse_address = <ls_entity>-WarehouseAddress.
      ENDIF.
      IF <ls_entity>-Comments IS NOT INITIAL.
        <ls_update_data>-comments = <ls_entity>-Comments.
      ENDIF.
      IF <ls_entity>-Qty IS NOT INITIAL.
        <ls_update_data>-qty = <ls_entity>-Qty.
      ENDIF.
      IF <ls_entity>-Unit IS NOT INITIAL.
        <ls_update_data>-unit = <ls_entity>-Unit.
      ENDIF.

      " Update the entry in the persistent table
      UPDATE zse_431 SET
        warehouse_id = @<ls_update_data>-warehouse_id,
        warehouse_address = @<ls_update_data>-warehouse_address,
        comments = @<ls_update_data>-comments,
        Qty  = @<ls_update_data>-Qty ,
        unit  = @<ls_update_data>-unit ,
        lastchange = @<ls_update_data>-lastchange
      WHERE so_id = @<ls_update_data>-so_id
        AND extra_id = @<ls_update_data>-extra_id.

      " Check if the update was successful and handle any errors
      IF sy-subrc <> 0.
        " Handle the error case
        "RAISE EXCEPTION TYPE cx_abap_update_failed.
      ENDIF.
    ELSE.
      " Handle the case where the entry does not exist
      "RAISE EXCEPTION TYPE cx_abap_update_failed.
    ENDIF.
  ENDLOOP.
  ENDMETHOD.

  METHOD delete.
      " Define a work area to hold the key of the entry to be deleted
    "DATA: ls_delete_key TYPE zse_431.

    " Loop through the keys parameter to extract the keys
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>). "INTO DATA(ls_key).
      " Map the key fields to the work area
     " ls_delete_key-so_id = ls_key-so_id.
      "ls_delete_key-item_id = ls_key-item_id.  " Ensure the item number is also mapped

      " Delete the entry from the persistent table
      DELETE FROM zse_431 WHERE so_id    = @<fs_key>-SoId and
                                 extra_id = @<fs_key>-ExtraId.

      " Check if the delete was successful and handle any errors
      IF sy-subrc <> 0.
        " Handle the error case
        "RAISE EXCEPTION TYPE cx_abap_delete_failed.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
   SELECT * FROM  zse_431 FOR ALL ENTRIES IN @keys
      WHERE so_id  = @keys-SoId
            and extra_id = @keys-ExtraId
      INTO TABLE @DATA(lt_extra_data).

    result = CORRESPONDING #( lt_extra_data MAPPING TO ENTITY ).
  ENDMETHOD.

  METHOD rba_Sale.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZISH_431 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZISH_431 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
