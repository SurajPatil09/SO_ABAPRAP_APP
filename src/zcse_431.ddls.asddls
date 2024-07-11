@EndUserText.label: 'EXTRA PROJECTION VIEW'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCSE_431 as projection on ZISE_431
{
    key SoId,
    key ExtraId,
    Unit,
    Qty,
    WarehouseId,
    WarehouseAddress,
    Comments,
    Lastchange,
    /* Associations */
    _SALE : redirected to parent ZCSH_431,
    _wh
}
