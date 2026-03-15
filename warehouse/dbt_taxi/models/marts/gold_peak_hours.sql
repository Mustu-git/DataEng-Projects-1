with trips as (

    select * from {{ ref('stg_taxi_trips') }}

),

hourly as (

    select
        extract(hour from pickup_ts)::integer as hour_of_day,
        count(*) as trip_count,
        avg(trip_duration_mins) as avg_trip_duration_mins,
        avg(total_amount) as avg_total_amount
    from trips
    where pickup_ts is not null
    group by 1

)

select * from hourly
order by hour_of_day
