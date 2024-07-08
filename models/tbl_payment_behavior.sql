{{ config(materialized='table') }}

with customers_source as (select * from {{ref('stg_customers')}})
, orders_source as (select * from {{ref('stg_orders')}})
, payments_source as (select * from {{ref('stg_payment')}})

, customers as
(
    select CustomerId
        , FirstName
        , LastName
    from customers_source
)

, orders as
(
    select OrderId
        , UserId
    from orders_source
)

, payments as
(
    select PaymentId
        , OrderId
        , PaymentMethod
        , Amount
    from payments_source
)

, orders_customers as
(
    select c.CustomerId
        , c.FirstName
        , c.LastName
        , o.OrderId
    from customers as c
        right join orders as o on c.CustomerId = o.UserId
)

, payment_behavior as
(
    select oc.CustomerId
        , oc.FirstName
        , oc.LastName
        , sum(p.Amount) as CustomerLifetimeValue
        , p.PaymentMethod
        , count(p.PaymentId) as PaymentCount
    from orders_customers as oc
        right join payments as p on oc.OrderId = p.OrderId
    group by p.PaymentMethod
    order by CustomerLifetimeValue
)

select * from payment_behavior