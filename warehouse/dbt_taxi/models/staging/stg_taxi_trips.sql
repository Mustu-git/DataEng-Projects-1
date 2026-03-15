with source as (

    select * from {{ source('raw', 'taxi_trips') }}

),

cleaned as (

    select
        -- Keep these generic for now; we'll align exact column names once we load a sample month
        tpep_pickup_datetime                as pickup_ts,
        tpep_dropoff_datetime               as dropoff_ts,

        cast("PULocationID" as integer)     as pickup_location_id,
        cast("DOLocationID" as integer)     as dropoff_location_id,

        cast(passenger_count as integer)    as passenger_count,
        trip_distance,

        fare_amount,
        tip_amount,
        total_amount,

        cast(payment_type as integer)       as payment_type,

        -- Derived: trip duration in minutes
        case
            when tpep_dropoff_datetime >= tpep_pickup_datetime
            then extract(epoch from (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60.0
            else null
        end as trip_duration_mins,

        -- Derived: weekend flag (Sunday=0, Saturday=6 in PostgreSQL DOW)
        case
            when extract(dow from tpep_pickup_datetime) in (0, 6) then true
            else false
        end as is_weekend

    from source

)

select * from cleaned
