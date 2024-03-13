with source as (

    select * from dbtyaky.stripe.raw_payment

)

, renamed as (

    select
        cast(id as string) as PaymentId
        , cast(orderid as string) as OrderId
        , cast(paymentmethod as string) as PaymentMethod
        , cast(status as string) as PaymentStatus
        , cast(amount as integer) as Amount
        , cast(created as date) as Created
        , cast(_batched_at as timestamp) as BatchedAt
    from source

)

select * from renamed