with trips as (

    select * from {{ ref('stg_taxi_trips') }}

),

flagged as (

    select
        pickup_ts,
        dropoff_ts,
        pickup_location_id,
        dropoff_location_id,
        passenger_count,
        trip_distance,
        fare_amount,
        total_amount,
        payment_type,
        trip_duration_mins,

        -- Flag each anomaly type
        case when trip_duration_mins < 0                then true else false end as is_negative_duration,
        case when trip_duration_mins > 180              then true else false end as is_over_3hrs,
        case when trip_distance > 100                   then true else false end as is_over_100miles,
        case when fare_amount <= 0                      then true else false end as is_zero_neg_fare,
        case when total_amount > 500                    then true else false end as is_high_fare,
        case when passenger_count = 0                   then true else false end as is_zero_passengers,
        case when passenger_count > 6                   then true else false end as is_over_6_passengers

    from trips

),

anomalies as (

    -- Only keep rows that triggered at least one flag
    select
        *,
        (is_negative_duration::int
            + is_over_3hrs::int
            + is_over_100miles::int
            + is_zero_neg_fare::int
            + is_high_fare::int
            + is_zero_passengers::int
            + is_over_6_passengers::int
        ) as anomaly_count
    from flagged
    where
        is_negative_duration
        or is_over_3hrs
        or is_over_100miles
        or is_zero_neg_fare
        or is_high_fare
        or is_zero_passengers
        or is_over_6_passengers

)

select * from anomalies
order by anomaly_count desc, pickup_ts
