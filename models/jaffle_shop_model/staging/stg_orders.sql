{{ config(materialized='table') }}

with source as (

    select * from dbtyaky.jaffle_shop.raw_orders

)

, renamed as (

    select
        cast(id as string) as OrderId
        , cast(user_id as string) as UserId
        , cast(order_date as date) as OrderDate
        , cast(status as string) as OrderStatus
        , cast(_etl_loaded_at as timestamp) as EtlLoadedAt
    from source

)

select * from renamed