-- Each day's balances must follow from the previous day's balance plus that day's net flow.
-- The source does not record intra-day order, so the check accepts any pairing of the
-- previous day's and current day's balances. Tolerance 0.50 CZK: about 5.7% of account-days
-- differ by up to 0.20 CZK because interest postings are rounded differently from balances.
with daily as (
    select account_id, trans_date, sum(signed_amount_czk) as net, list(balance_after_czk) as bals
    from {{ ref('stg_berka__transactions') }}
    group by 1, 2
),

d as (
    select *, lag(bals) over (partition by account_id order by trans_date) as prev_bals
    from daily
),

pairs as (
    select account_id, trans_date, net, unnest(prev_bals) as prev_balance, bals
    from d
    where prev_bals is not null
)

select account_id, trans_date
from pairs
group by account_id, trans_date
having not bool_or(list_bool_or(list_transform(bals, b -> abs(prev_balance + net - b) <= 0.5)))
