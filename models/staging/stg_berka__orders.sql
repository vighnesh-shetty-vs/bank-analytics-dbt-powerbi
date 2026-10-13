select
    cast(order_id as integer)            as order_id,
    cast(account_id as integer)          as account_id,
    bank_to                              as recipient_bank,
    account_to                           as recipient_account,
    cast(amount as decimal(12, 2))       as amount_czk,
    case nullif(trim(k_symbol), '')
        when 'POJISTNE' then 'insurance'
        when 'SIPO'     then 'household payment'
        when 'LEASING'  then 'leasing'
        when 'UVER'     then 'loan payment'
    end                                  as purpose
from {{ source('berka', 'order') }}
