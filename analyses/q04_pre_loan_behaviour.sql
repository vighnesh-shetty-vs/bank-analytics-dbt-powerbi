-- Q4. Could the bank have seen defaults coming? Default rate by behaviour BEFORE the loan
-- (features use only pre-grant transactions, so this is information the bank had).
with f as (
    select
        *,
        ntile(4) over (order by payment_to_inflow_ratio) as affordability_quartile
    from {{ ref('fct_loans') }}
)
select 'overdrawn before loan' as signal, (n_negative_balance_events > 0)::varchar as bucket,
       count(*) as loans, round(100.0 * avg(is_default::int), 1) as default_rate_pct
from f group by 1, 2
union all
select 'payment / avg monthly inflow (quartile, 4 = least affordable)', affordability_quartile::varchar,
       count(*), round(100.0 * avg(is_default::int), 1)
from f group by 1, 2
union all
select 'min balance in last 90 days < 5,000 CZK', (min_balance_90d_czk < 5000)::varchar,
       count(*), round(100.0 * avg(is_default::int), 1)
from f group by 1, 2
order by 1, 2
