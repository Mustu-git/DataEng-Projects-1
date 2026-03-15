with trips as (

    select * from {{ ref('stg_taxi_trips') }}

),

zone_counts as (

    select
        pickup_location_id,
        count(*) as trip_count
    from trips
    where pickup_location_id is not null
    group by 1

),

ranked as (

    select
        pickup_location_id,
        trip_count,
        rank() over (order by trip_count desc) as demand_rank
    from zone_counts

)

select * from ranked
order by demand_rank
