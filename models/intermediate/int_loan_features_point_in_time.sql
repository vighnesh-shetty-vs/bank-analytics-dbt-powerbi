-- Behavioural features for each loan, computed ONLY from transactions dated before the
-- loan was granted. Using later transactions would leak the outcome: the dataset guide
-- notes that bad loans are perfectly separable by "balance ever negative" if time is ignored.
with loans as (
    select loan_id, account_id, granted_date from {{ ref('stg_berka__loans') }}
),

history as (
    select
        l.loan_id,
        l.granted_date,
        t.trans_date,
        t.direction,
        t.amount_czk,
        t.balance_after_czk,
        t.purpose
    from loans l
    join {{ ref('stg_berka__transactions') }} t
      on t.account_id = l.account_id
     and t.trans_date < l.granted_date
)

select
    loan_id,
    count(*)                                                                              as n_transactions_before,
    max(trans_date)                                                                       as last_transaction_date_used,
    avg(balance_after_czk) filter (where trans_date >= granted_date - interval 90 day)    as avg_balance_90d_czk,
    min(balance_after_czk) filter (where trans_date >= granted_date - interval 90 day)    as min_balance_90d_czk,
    sum(amount_czk) filter (where direction = 'credit'
                              and trans_date >= granted_date - interval 180 day) / 6      as avg_monthly_inflow_6m_czk,
    sum(amount_czk) filter (where direction = 'debit'
                              and trans_date >= granted_date - interval 180 day) / 6      as avg_monthly_outflow_6m_czk,
    count(*) filter (where balance_after_czk < 0)                                         as n_negative_balance_events,
    count(*) filter (where purpose = 'penalty interest')                                  as n_penalty_interest_charges
from history
group by loan_id
