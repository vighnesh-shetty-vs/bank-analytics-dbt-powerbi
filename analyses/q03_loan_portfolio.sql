-- Q3. Loan book overview: volume, exposure and default rate by loan duration.
select
    duration_months,
    count(*)                                                     as loans,
    round(sum(loan_amount_czk) / 1e6, 1)                         as exposure_m_czk,
    round(avg(loan_amount_czk))                                  as avg_loan_czk,
    sum(is_default::int)                                         as defaults,
    round(100.0 * avg(is_default::int), 1)                       as default_rate_pct,
    round(100.0 * sum(loan_amount_czk) filter (where is_default)
          / sum(loan_amount_czk), 1)                             as exposure_in_default_pct
from {{ ref('fct_loans') }}
group by rollup (duration_months)
order by duration_months nulls last
