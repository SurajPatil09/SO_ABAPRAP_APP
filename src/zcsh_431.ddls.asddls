@EndUserText.label: 'sale projection view'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZCSH_431
  provider contract transactional_query as projection on ZISH_431
{
    key SoId,
    CustomerId,
    CustomerDesc,
    Salestatus,
    SoDate,
    LocalLastChangedAt,
    /* Associations */
    _EXTRA : redirected to composition child ZCSE_431,
    _ITEM  : redirected to composition child ZCSI_431,
    _customer
}
