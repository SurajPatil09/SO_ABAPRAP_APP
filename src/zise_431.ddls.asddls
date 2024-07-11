@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EXTRA VIEW'
define view entity ZISE_431 as select from zse_431
association to parent ZISH_431 as _SALE on $projection.SoId = _SALE.SoId
association [1..1] to ZI_WHDB as _wh     on  $projection.WarehouseId = _wh.WarehouseId
{
    key so_id as SoId,
    key extra_id as ExtraId,
    unit as Unit,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    qty as Qty,
    warehouse_id as WarehouseId,
    warehouse_address as WarehouseAddress,
    comments as Comments,
    lastchange as Lastchange,
    // Make association public
    _SALE,
    _wh
}
