-- Daily calendar covering the data range (1993-1998), for Power BI time intelligence.
select
    d::date                                   as date_day,
    year(d)                                   as year,
    quarter(d)                                as quarter,
    month(d)                                  as month,
    strftime(d, '%Y-%m')                      as year_month,
    strftime(d, '%b %Y')                      as month_label,
    date_trunc('month', d)::date              as month_start,
    isodow(d)                                 as iso_weekday,
    isodow(d) >= 6                            as is_weekend
from range(date '1993-01-01', date '1999-01-01', interval 1 day) as t(d)
