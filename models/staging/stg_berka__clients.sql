with src as (
    select
        cast(client_id as integer)   as client_id,
        cast(district_id as integer) as district_id,
        birth_number
    from {{ source('berka', 'client') }}
)

select
    client_id,
    district_id,
    -- women have 50 added to the birth month
    case when (cast(birth_number as integer) // 100) % 100 > 50 then 'F' else 'M' end as gender,
    make_date(
        1900 + cast(birth_number as integer) // 10000,
        {{ berka_birth_month('birth_number') }},
        cast(birth_number as integer) % 100
    )                                                                                 as birth_date
from src
