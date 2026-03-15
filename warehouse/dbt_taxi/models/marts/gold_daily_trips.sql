with trips as (

    select * from {{ ref('stg_taxi_trips') }}

),

daily as (

    select
        date_trunc('day', pickup_ts)::date as trip_date,
        count(*) as trip_count,
        avg(trip_distance) as avg_trip_distance,
        avg(total_amount) as avg_total_amount,
        sum(total_amount) as total_revenue
    from trips
    where pickup_ts is not null
    group by 1

)

select * from daily
