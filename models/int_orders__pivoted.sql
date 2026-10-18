{%- set paymentmethods=['bank_transfer', 'coupon', 'credit_card', 'gift_card'] -%}

with payments as (
    select * from {{ref('stg_stripe__payment')}}
    where payment_status = 'success'
)

, pivoted as (
    select 
        order_id, 
        {% for method in paymentmethods %}
            sum(case when paymentmethod = '{{method}}' then payment_amount else 0 end) as {{method}}_amount
            {%- if not loop.last -%}
                ,
            {%- endif -%}
        {% endfor %}
    from payments 
    group by 1 
)

select * 
from pivoted