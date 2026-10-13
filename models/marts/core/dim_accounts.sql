with disp as (select * from {{ ref('stg_berka__dispositions') }}),
cards as (
    select d.account_id,
           max(case c.card_type when 'gold' then 3 when 'classic' then 2 when 'junior' then 1 end) as card_rank
    from {{ ref('stg_berka__cards') }} c
    join disp d using (disp_id)
    group by 1
),
loans as (select account_id, loan_id from {{ ref('stg_berka__loans') }})

select
    a.account_id,
    a.district_id,
    a.opened_date,
    a.statement_frequency,
    o.client_id                                                     as owner_client_id,
    count(u.disp_id)                                                as n_authorised_users,
    coalesce(cards.card_rank, 0) > 0                                as has_card,
    case cards.card_rank when 3 then 'gold' when 2 then 'classic' when 1 then 'junior' else 'none' end
                                                                    as best_card_type,
    loans.loan_id is not null                                       as has_loan,
    loans.loan_id
from {{ ref('stg_berka__accounts') }} a
join disp o  on o.account_id = a.account_id and o.disposition_type = 'owner'
left join disp u on u.account_id = a.account_id and u.disposition_type = 'disponent'
left join cards  on cards.account_id = a.account_id
left join loans  on loans.account_id = a.account_id
group by all
