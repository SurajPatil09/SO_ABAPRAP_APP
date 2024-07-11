@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'sale item view'
define view entity ZISI_431 as select from zsi_431
association to parent ZISH_431 as _SALE on $projection.SoId = _SALE.SoId
association [1..1] to ZI_MODB    as _material on $projection.MaterialNo = _material.MaterialNo
association [0..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
{
    key so_id as SoId,
    key item_id as ItemId,
    material_no as MaterialNo,
    material_desc as MaterialDesc,
    currency_code as CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    amount as Amount,
    lastchange as Lastchange,
    // Make association public
    _SALE,
    _material,
    _Currency
}
