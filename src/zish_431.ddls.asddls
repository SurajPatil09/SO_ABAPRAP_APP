@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sale header view'
define root view entity ZISH_431 as select from zsh_431
composition [0..*] of ZISI_431  as _ITEM
composition [0..*] of ZISE_431  as _EXTRA
association [1..1] to ZI_CTDB as _customer on $projection.CustomerId = _customer.CustomerId

{
    key so_id as SoId,
    customer_id as CustomerId,
    customer_desc as CustomerDesc,
    salestatus as Salestatus,
    so_date as SoDate,
    local_last_changed_at as LocalLastChangedAt,
   // Make association public
   _ITEM,
   _EXTRA,
   _customer
    
}
