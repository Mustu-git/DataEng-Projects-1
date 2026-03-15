{{
    config(
        materialized='incremental',
        unique_key='trip_date'
    )
}}

with trips as (

    select * from {{ ref('stg_taxi_trips') }}

    {% if is_incremental() %}
        -- On incremental runs, only process dates newer than what's already loaded
        where pickup_ts > (select max(trip_date) from {{ this }})
    {% endif %}

),

daily as (

    select
        date_trunc('day', pickup_ts)::date  as trip_date,
        count(*)                            as trip_count,
        round(avg(fare_amount)::numeric, 2) as avg_fare,
        round(avg(trip_distance)::numeric, 2) as avg_trip_distance,
        round(avg(total_amount)::numeric, 2) as avg_total_amount,
        round(sum(total_amount)::numeric, 2) as total_revenue
    from trips
    where pickup_ts is not null
    group by 1

)

select * from daily
