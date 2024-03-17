{{ config(materialized='table') }}

with source as 
(
    select * from {{ref('raw_customers')}}
)

, renamed as 
(
    select
        cast(id as string) as CustomerId
        , cast(first_name as string) as FirstName
        , cast(last_name as string) as LastName 
    from source
)

select * from renamed