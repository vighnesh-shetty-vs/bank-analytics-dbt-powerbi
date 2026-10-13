select t.trans_id, t.trans_date, a.opened_date
from {{ ref('stg_berka__transactions') }} t
join {{ ref('stg_berka__accounts') }} a using (account_id)
where t.trans_date < a.opened_date
