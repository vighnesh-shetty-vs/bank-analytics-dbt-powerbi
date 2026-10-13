-- Guard against target leakage: no feature may use a transaction on or after the grant date.
select loan_id, granted_date, last_transaction_date_used
from {{ ref('fct_loans') }}
where last_transaction_date_used >= granted_date
