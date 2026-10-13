-- Q10. When is cash demand highest? Cash withdrawals by calendar month (1996-1998 average),
-- indexed to the yearly monthly average = 100. Useful for branch/ATM cash planning.
with m as (
    select month(trans_date) as month, year(trans_date) as year, sum(amount_czk) as cash_out
    from {{ ref('fct_transactions') }}
    where operation = 'cash withdrawal' and year(trans_date) between 1996 and 1998
    group by 1, 2
),
indexed as (
    select month, year, 100.0 * cash_out / avg(cash_out) over (partition by year) as idx
    from m
)
select
    month,
    strftime(make_date(2000, month, 1), '%b') as month_name,
    round(avg(idx), 1)                        as cash_index
from indexed
group by month
order by month
