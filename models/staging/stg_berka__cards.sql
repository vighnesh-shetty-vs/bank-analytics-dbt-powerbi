select
    cast(card_id as integer)                                as card_id,
    cast(disp_id as integer)                                as disp_id,
    type                                                    as card_type,   -- junior | classic | gold
    {{ berka_date("left(issued, 6)") }}                     as issued_date
from {{ source('berka', 'card') }}
