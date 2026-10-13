-- Q2. Where are the deposits? Balances at December 1998 by region, and balance per account.
select
    d.region,
    sum(k.active_accounts)                                              as active_accounts_dec98,
    round(sum(k.month_end_balance_czk) / 1e6, 1)                        as balances_m_czk,
    round(sum(k.month_end_balance_czk) / sum(k.active_accounts))        as balance_per_account_czk,
    round(100.0 * sum(k.month_end_balance_czk)
          / sum(sum(k.month_end_balance_czk)) over (), 1)               as share_of_balances_pct
from {{ ref('rpt_monthly_kpis') }} k
join {{ ref('dim_districts') }} d using (district_id)
where k.month_start = date '1998-12-01'
group by d.region
order by balances_m_czk desc
