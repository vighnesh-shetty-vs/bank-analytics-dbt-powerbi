-- Q8. Where do accounts go overdrawn? Districts with the highest share of account-months
-- with a negative balance (minimum 1,000 account-months for stability).
select
    d.district_name,
    d.region,
    sum(k.active_accounts)                                                         as account_months,
    sum(k.accounts_with_negative_balance)                                          as overdrawn_account_months,
    round(100.0 * sum(k.accounts_with_negative_balance) / sum(k.active_accounts), 2) as overdrawn_pct,
    rank() over (order by sum(k.accounts_with_negative_balance) * 1.0 / sum(k.active_accounts) desc) as rank
from {{ ref('rpt_monthly_kpis') }} k
join {{ ref('dim_districts') }} d using (district_id)
group by 1, 2
having sum(k.active_accounts) >= 1000
qualify rank <= 10
order by rank
