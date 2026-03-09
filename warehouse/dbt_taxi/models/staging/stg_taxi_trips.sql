with source as (

    select * from {{ source('raw', 'taxi_trips') }}

),

cleaned as (

    select
        -- Keep these generic for now; we'll align exact column names once we load a sample month
        cast(pickup_datetime as timestamp)  as pickup_ts,
        cast(dropoff_datetime as timestamp) as dropoff_ts,

        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,

        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as double precision) as trip_distance,

        cast(fare_amount as double precision) as fare_amount,
        cast(tip_amount as double precision)  as tip_amount,
        cast(total_amount as double precision) as total_amount,

        cast(payment_type as integer) as payment_type,

        -- A simple derived field we can benchmark with
        case
            when dropoff_datetime >= pickup_datetime
            then extract(epoch from (cast(dropoff_datetime as timestamp) - cast(pickup_datetime as timestamp))) / 60.0
            else null
        end as trip_duration_min

    from source

)

select * from cleaned
