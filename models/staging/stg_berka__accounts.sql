select
    cast(account_id as integer)                       as account_id,
    cast(district_id as integer)                      as district_id,
    case frequency
        when 'POPLATEK MESICNE'   then 'monthly'
        when 'POPLATEK TYDNE'     then 'weekly'
        when 'POPLATEK PO OBRATU' then 'after_transaction'
    end                                               as statement_frequency,
    {{ berka_date('date') }}                          as opened_date
from {{ source('berka', 'account') }}
