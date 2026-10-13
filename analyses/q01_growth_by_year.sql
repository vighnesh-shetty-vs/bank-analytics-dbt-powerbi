-- Q1. How fast did the bank grow? Accounts opened, active accounts and money flows per year.
with yearly as (
    select
        year(month_start)                       as year,
        sum(new_accounts)                       as accounts_opened,
        sum(transactions)                       as transactions,
        round(sum(inflow_czk) / 1e6, 1)         as inflow_m_czk,
        round(sum(outflow_czk) / 1e6, 1)        as outflow_m_czk
    from {{ ref('rpt_monthly_kpis') }}
    group by 1
),
active as (
    select year(month_start) as year, count(distinct account_id) as active_accounts
    from {{ ref('int_account_months') }}
    group by 1
)
select
    y.year,
    y.accounts_opened,
    a.active_accounts,
    y.transactions,
    y.inflow_m_czk,
    y.outflow_m_czk,
    round(100.0 * (y.transactions / lag(y.transactions) over (order by y.year) - 1), 1) as txn_growth_pct
from yearly y join active a using (year)
order by y.year
