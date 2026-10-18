with 

source as (

    select * from {{ source('stripe', 'payment') }}

),

renamed as (

    select
        id as payment_id,
        orderid as order_id,
        paymentmethod,
        status as payment_status,
        {{cents_to_dollars("amount")}} as payment_amount,
        created,
        _batched_at

    from source

)

select * from renamed