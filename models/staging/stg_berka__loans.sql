select
    cast(loan_id as integer)                         as loan_id,
    cast(account_id as integer)                      as account_id,
    {{ berka_date('date') }}                         as granted_date,
    cast(amount as decimal(12, 2))                   as loan_amount_czk,
    cast(duration as integer)                        as duration_months,
    cast(payments as decimal(12, 2))                 as monthly_payment_czk,
    status                                           as status_code,
    case status
        when 'A' then 'finished, repaid'
        when 'B' then 'finished, not repaid'
        when 'C' then 'running, on track'
        when 'D' then 'running, in debt'
    end                                              as status_description,
    status in ('A', 'B')                             as is_finished,
    status in ('B', 'D')                             as is_default
from {{ source('berka', 'loan') }}
