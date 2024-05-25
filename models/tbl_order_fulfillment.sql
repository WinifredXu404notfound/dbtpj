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
        , OrderDate as OrderCreated
        , OrderStatus
    from orders_source
)

, payments as
(
    select PaymentId
        , OrderId
        , PaymentStatus
        , Amount
        , Created as PaymentCreated
    from payments_source
)

, orders2customers as
(
    select c.CustomerId
        , c.FirstName
        , c.LastName
        , o.OrderId
        , o.OrderStatus
        , o.OrderCreated
    from customers as c
        right join orders as o on c.CustomerId = o.UserId
)

, order_fulfillment as
(
    select o2c.CustomerId
        , o2c.FirstName
        , o2c.LastName
        , sum(p.Amount) as CustomerLifetimeValue
        , o2c.OrderId
        , p.PaymentId
        , o2c.OrderStatus
        , p.PaymentStatus
        , o2c.OrderCreated
        , p.PaymentCreated
    from orders2customers as o2c
        right join payments as p on o2c.OrderId = p.OrderId
    when p.PaymentStatus = 'success'
    order by CustomerLifetimeValue DESC
)

select * from order_fulfillment