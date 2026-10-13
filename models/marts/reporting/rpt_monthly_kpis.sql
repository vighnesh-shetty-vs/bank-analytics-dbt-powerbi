-- Month x district KPI table feeding the Power BI report (small enough to ship as CSV).
with months as (select * from {{ ref('int_account_months') }}),
accounts as (select account_id, district_id, opened_date from {{ ref('dim_accounts') }}),
activity as (
    select
        m.month_start,
        a.district_id,
        count(distinct m.account_id)                       as active_accounts,
        sum(m.n_transactions)                              as transactions,
        sum(m.inflow_czk)                                  as inflow_czk,
        sum(m.outflow_czk)                                 as outflow_czk,
        sum(m.net_flow_czk)                                as net_flow_czk,
        sum(m.card_spend_czk)                              as card_spend_czk,
        sum(m.month_end_balance_czk)                       as month_end_balance_czk,
        count(*) filter (where m.had_negative_balance)     as accounts_with_negative_balance
    from months m join accounts a using (account_id)
    group by 1, 2
),
openings as (
    select date_trunc('month', opened_date)::date as month_start, district_id, count(*) as new_accounts
    from accounts group by 1, 2
)
select
    coalesce(x.month_start, o.month_start)   as month_start,
    coalesce(x.district_id, o.district_id)   as district_id,
    coalesce(x.active_accounts, 0)           as active_accounts,
    coalesce(o.new_accounts, 0)              as new_accounts,
    coalesce(x.transactions, 0)              as transactions,
    coalesce(x.inflow_czk, 0)                as inflow_czk,
    coalesce(x.outflow_czk, 0)               as outflow_czk,
    coalesce(x.net_flow_czk, 0)              as net_flow_czk,
    coalesce(x.card_spend_czk, 0)            as card_spend_czk,
    coalesce(x.month_end_balance_czk, 0)     as month_end_balance_czk,
    coalesce(x.accounts_with_negative_balance, 0) as accounts_with_negative_balance
from activity x
full outer join openings o
    on x.month_start = o.month_start and x.district_id = o.district_id
