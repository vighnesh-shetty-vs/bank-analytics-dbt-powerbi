-- Q6. Are card holders more valuable? Activity and balances in 1998 by best card on the account.
with m as (
    select account_id, avg(month_end_balance_czk) as avg_balance, avg(n_transactions) as txns_per_month,
           avg(card_spend_czk) as card_spend_per_month
    from {{ ref('int_account_months') }}
    where year(month_start) = 1998
    group by 1
)
select
    a.best_card_type,
    count(*)                                     as accounts,
    round(avg(m.avg_balance))                    as avg_balance_czk,
    round(avg(m.txns_per_month), 1)              as txns_per_month,
    round(avg(coalesce(m.card_spend_per_month, 0))) as card_spend_per_month_czk,
    round(100.0 * avg(a.has_loan::int), 1)       as loan_uptake_pct
from {{ ref('dim_accounts') }} a
join m using (account_id)
group by 1
order by avg_balance_czk desc
