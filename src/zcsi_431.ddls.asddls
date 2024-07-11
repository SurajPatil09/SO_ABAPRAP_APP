@EndUserText.label: 'sale item view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZCSI_431 as projection on ZISI_431
{
    key SoId,
    key ItemId,
    MaterialNo,
    MaterialDesc,
    CurrencyCode,
    Amount,
    Lastchange,
    /* Associations */
    _Currency,
    _material,
    _SALE : redirected to parent ZCSH_431
}
