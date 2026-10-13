-- Q5. Does the local economy matter? Default rate by district unemployment (1996) tercile.
with l as (
    select
        f.*,
        d.unemployment_rate_1996_pct,
        ntile(3) over (order by d.unemployment_rate_1996_pct) as unemployment_tercile
    from {{ ref('fct_loans') }} f
    join {{ ref('dim_districts') }} d using (district_id)
)
select
    case unemployment_tercile when 1 then 'low' when 2 then 'medium' else 'high' end as unemployment,
    round(min(unemployment_rate_1996_pct), 2) || '-' || round(max(unemployment_rate_1996_pct), 2) as range_pct,
    count(*)                                   as loans,
    round(100.0 * avg(is_default::int), 1)     as default_rate_pct
from l
group by unemployment_tercile
order by unemployment_tercile
