select
    trans_id,
    account_id,
    trans_date,
    date_trunc('month', trans_date)::date as month_start,
    direction,
    operation,
    purpose,
    amount_czk,
    signed_amount_czk,
    balance_after_czk
from {{ ref('stg_berka__transactions') }}
