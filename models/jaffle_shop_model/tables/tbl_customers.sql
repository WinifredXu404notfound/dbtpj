{{ config(materialized='table') }}

with customers as (

    select * from {{ ref('stg_customers') }}

) 

, with orders as (

    select * from {{ ref('stg_orders') }}
    
    ) 

, with payments as (

    select * from {{ ref('stg_payment') }}

    ) 