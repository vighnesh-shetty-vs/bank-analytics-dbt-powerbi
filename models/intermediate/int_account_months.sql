-- One row per account per calendar month with activity.
-- Month-end balance = balance after the last transaction of the month. Within a day the
-- source does not record transaction order, so ties are broken by trans_id (approximation).
select
    account_id,
    date_trunc('month', trans_date)::date                                  as month_start,
    count(*)                                                               as n_transactions,
    sum(amount_czk) filter (where direction = 'credit')                    as inflow_czk,
    sum(amount_czk) filter (where direction = 'debit')                     as outflow_czk,
    sum(signed_amount_czk)                                                 as net_flow_czk,
    sum(amount_czk) filter (where operation = 'card withdrawal')           as card_spend_czk,
    arg_max(balance_after_czk, trans_date::varchar || lpad(trans_id::varchar, 10, '0')) as month_end_balance_czk,
    bool_or(balance_after_czk < 0)                                         as had_negative_balance
from {{ ref('stg_berka__transactions') }}
group by 1, 2
