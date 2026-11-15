{{ config(materialized='view') }}

-- Unversioned, stable interface over fct_orders v2 for the dbt Semantic Layer.
-- Pinned to v2 explicitly so it does not follow changes to latest_version.

with orders_v2 as (

    select * from {{ ref('fct_orders', v=2) }}

)

select
    order_id,
    customer_id,
    order_date,
    payment_amount
from orders_v2
