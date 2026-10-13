-- One row per loan with point-in-time behaviour features, owner demographics and district context.
select
    l.loan_id,
    l.account_id,
    l.granted_date,
    date_trunc('month', l.granted_date)::date                         as granted_month,
    l.loan_amount_czk,
    l.duration_months,
    l.monthly_payment_czk,
    l.status_code,
    l.status_description,
    l.is_finished,
    l.is_default,
    a.district_id,
    a.statement_frequency,
    a.best_card_type,
    c.gender                                                          as owner_gender,
    date_diff('year', c.birth_date, l.granted_date)                   as owner_age_at_grant,
    date_diff('day', a.opened_date, l.granted_date)                   as account_age_days_at_grant,
    f.n_transactions_before,
    f.last_transaction_date_used,
    f.avg_balance_90d_czk,
    f.min_balance_90d_czk,
    f.avg_monthly_inflow_6m_czk,
    f.avg_monthly_outflow_6m_czk,
    f.n_negative_balance_events,
    f.n_penalty_interest_charges,
    l.monthly_payment_czk / nullif(f.avg_monthly_inflow_6m_czk, 0)    as payment_to_inflow_ratio,
    l.loan_amount_czk / nullif(f.avg_balance_90d_czk, 0)              as loan_to_balance_ratio
from {{ ref('stg_berka__loans') }} l
join {{ ref('dim_accounts') }} a on a.account_id = l.account_id
join {{ ref('dim_clients') }} c on c.client_id = a.owner_client_id
left join {{ ref('int_loan_features_point_in_time') }} f on f.loan_id = l.loan_id
