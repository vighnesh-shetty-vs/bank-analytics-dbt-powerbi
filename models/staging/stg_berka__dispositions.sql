select
    cast(disp_id as integer)    as disp_id,
    cast(client_id as integer)  as client_id,
    cast(account_id as integer) as account_id,
    lower(type)                 as disposition_type   -- owner | disponent (authorised user)
from {{ source('berka', 'disp') }}
