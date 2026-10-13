-- Q7. How are customers moving money? Share of debit volume by channel, per year.
with debits as (
    select year(trans_date) as year, coalesce(operation, 'other') as channel, sum(amount_czk) as volume
    from {{ ref('fct_transactions') }}
    where direction = 'debit'
    group by 1, 2
)
select
    year,
    round(100.0 * sum(volume) filter (where channel = 'cash withdrawal') / sum(volume), 1) as cash_pct,
    round(100.0 * sum(volume) filter (where channel = 'transfer out')    / sum(volume), 1) as transfer_pct,
    round(100.0 * sum(volume) filter (where channel = 'card withdrawal') / sum(volume), 1) as card_pct
from debits
group by year
order by year
