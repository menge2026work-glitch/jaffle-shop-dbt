{{config(
    materialized='incremental',
    unique_key = 'order_id', 
    incremental_strategy='merge',
    on_schema_change='fail'
)}}

with orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

payments as (
    select * from {{ ref('stg_stripe__payment') }}
),

order_payments as (
    select 
        order_id  ,
        sum(case when payment_status = 'success' then payment_amount end) as total_amount_paid 
    from payments 
    group by 1 
), 

final as (
    select 
        orders.order_id,
        orders.customer_id,
        cast(orders.order_date as date) as order_date,
        coalesce(order_payments.total_amount_paid, 0) as payment_amount 
    from orders 
    left join order_payments using (order_id)
)

select * from final 
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where order_date >= (select max(order_date) from {{ this }}) 
{% endif %}
order by order_date desc