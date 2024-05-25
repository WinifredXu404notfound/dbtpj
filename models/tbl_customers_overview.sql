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
        , OrderDate
    from orders_source
)

, payments as
(
    select OrderId
        , Amount
    from payments_source
)

, customers_orders as
(
    select c.CustomerId
        , c.FirstName
        , c.LastName
        , min(o.OrderDate) as FirstOrder
        , max(o.OrderDate) as LatestOrder
        , count(o.OrderId) as TotalOrderCount
    from customers as c
        right join orders as o on c.CustomerId = o.UserId
    group by c.CustomerId
        , c.FirstName
        , c.LastName
)

, orders_payments as
(
    select o.UserId
        , sum(p.Amount) as CustomerLifetimeValue
    from orders as o
        right join payments as p on o.OrderId = p.OrderId
    group by o.UserId
)

, customers_overview as
(
    select co.CustomerId
        , co.FirstName
        , co.LastName
        , co.FirstOrder
        , co.LatestOrder
        , co.TotalOrderCount
        , op.CustomerLifetimeValue
    from customers_orders as co
        right join orders_payments as op on co.CustomerId = op.UserId
)

select * from customers_overview