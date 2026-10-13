-- In this dataset a loan amount equals monthly payment x duration (no separate interest line).
select loan_id, loan_amount_czk, monthly_payment_czk, duration_months
from {{ ref('stg_berka__loans') }}
where abs(loan_amount_czk - monthly_payment_czk * duration_months) > 1
