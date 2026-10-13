-- Column meanings from Berka's "Guide to the Financial Data Set"; '?' marks missing values.
select
    cast(A1 as integer)                         as district_id,
    A2                                          as district_name,
    A3                                          as region,
    cast(A4 as integer)                         as inhabitants,
    cast(A9 as integer)                         as n_cities,
    cast(A10 as double)                         as urban_inhabitants_pct,
    cast(A11 as integer)                        as avg_salary_czk,
    cast(nullif(A12, '?') as double)            as unemployment_rate_1995_pct,
    cast(A13 as double)                         as unemployment_rate_1996_pct,
    cast(A14 as integer)                        as entrepreneurs_per_1000,
    cast(nullif(A15, '?') as integer)           as crimes_1995,
    cast(A16 as integer)                        as crimes_1996
from {{ source('berka', 'district') }}
