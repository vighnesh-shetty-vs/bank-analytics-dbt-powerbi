-- Q9. Who are the customers? Account owners by age band: balances and loan uptake.
with balances as (
    select account_id, avg(month_end_balance_czk) as avg_balance
    from {{ ref('int_account_months') }}
    where year(month_start) = 1998
    group by 1
)
select
    c.age_band,
    count(*)                                   as owners,
    round(avg(b.avg_balance))                  as avg_balance_1998_czk,
    round(100.0 * avg(a.has_loan::int), 1)     as loan_uptake_pct,
    round(100.0 * avg(a.has_card::int), 1)     as card_uptake_pct
from {{ ref('dim_accounts') }} a
join {{ ref('dim_clients') }} c on c.client_id = a.owner_client_id
left join balances b using (account_id)
group by 1
order by 1
