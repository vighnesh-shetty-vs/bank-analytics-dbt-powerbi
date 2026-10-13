-- Czech codes translated using the dataset guide. 'VYBER' as a type is a cash withdrawal.
with src as (
    select
        cast(trans_id as integer)           as trans_id,
        cast(account_id as integer)         as account_id,
        {{ berka_date('date') }}            as trans_date,
        type,
        nullif(trim(operation), '')         as operation,
        cast(amount as decimal(12, 2))      as amount_czk,
        cast(balance as decimal(12, 2))     as balance_after_czk,
        nullif(trim(k_symbol), '')          as k_symbol,
        nullif(trim(bank), '')              as partner_bank,
        nullif(trim(account), '')           as partner_account
    from {{ source('berka', 'trans') }}
)

select
    trans_id,
    account_id,
    trans_date,
    case when type = 'PRIJEM' then 'credit' else 'debit' end            as direction,
    amount_czk,
    case when type = 'PRIJEM' then amount_czk else -amount_czk end      as signed_amount_czk,
    balance_after_czk,
    case operation
        when 'VYBER KARTOU'  then 'card withdrawal'
        when 'VKLAD'         then 'cash deposit'
        when 'PREVOD Z UCTU' then 'transfer in'
        when 'VYBER'         then 'cash withdrawal'
        when 'PREVOD NA UCET' then 'transfer out'
    end                                                                 as operation,
    case k_symbol
        when 'POJISTNE'    then 'insurance'
        when 'SLUZBY'      then 'statement fee'
        when 'UROK'        then 'interest credited'
        when 'SANKC. UROK' then 'penalty interest'
        when 'SIPO'        then 'household payment'
        when 'DUCHOD'      then 'pension'
        when 'UVER'        then 'loan payment'
    end                                                                 as purpose,
    partner_bank,
    partner_account
from src
