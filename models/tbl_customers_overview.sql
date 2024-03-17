{{ config(materialized='table') }}

with
    customers as 
    (
        select customerid
            , firstname
            , lastname 
        from {{ref('stg_customers')}}
    ),

    orders as 
    (
        select 
            orderid
            , userid
            , orderdate 
        from {{ref('stg_orders')}}
    ),

    payments as 
    (
        select 
            orderid
            , amount 
        from {{ref('stg_payment')}}
    ),

    customers_orders as 
    (
        select
            c.customerid,
            c.firstname,
            c.lastname,
            min(o.orderdate) as firstorder,
            max(o.orderdate) as latestorder,
            count(o.orderid) as totalordercount
        from customers as c
            right join orders as o on c.customerid = o.userid
    ),

    orders_payments as 
    (
        select 
            o.userid
            , p.sum(amount) as cusomterlifetimevalue
        from orders as o
            right join payments as p on o.orderid = p.orderid
    ),
    customers_overview as (
        select
            co.customerid,
            co.firstname,
            co.lastname,
            co.firstorder,
            co.latestorder,
            co.totalordercount,
            op.cusomterlifetimevalue
        from customers_orders as co
            right join orders_payments as op on co.customerid = op.userid
    )

select * from customers_overview