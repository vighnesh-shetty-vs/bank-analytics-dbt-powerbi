with c as (select * from {{ ref('stg_berka__clients') }})

select
    client_id,
    district_id,
    gender,
    birth_date,
    date_diff('year', birth_date, date '{{ var("as_of_date") }}')   as age_at_end_1998,
    case
        when date_diff('year', birth_date, date '{{ var("as_of_date") }}') < 25 then '18-24'
        when date_diff('year', birth_date, date '{{ var("as_of_date") }}') < 35 then '25-34'
        when date_diff('year', birth_date, date '{{ var("as_of_date") }}') < 50 then '35-49'
        when date_diff('year', birth_date, date '{{ var("as_of_date") }}') < 65 then '50-64'
        else '65+'
    end                                                                as age_band
from c
-- 18-24 band also contains a few under-18 clients (junior card holders); see README.
