# Query Benchmarks

## Setup
- Dataset: NYC Yellow Taxi January 2023 — 3,066,766 rows
- Database: PostgreSQL 15 running in Docker on localhost:5433
- Hardware: MacBook Air M2 8GB
- Both queries return identical results (36 rows, one per day)

## Benchmark: Daily Aggregation Query

### Query on raw.taxi_trips (3M rows, no pre-aggregation)
```sql
SELECT date_trunc('day', tpep_pickup_datetime)::date AS trip_date,
       count(*),
       sum(total_amount)
FROM raw.taxi_trips
GROUP BY 1
ORDER BY 1;
```
**Time: 2,463 ms (2.5 seconds)**

### Same query on staging.gold_daily_trips (36 rows, pre-aggregated table)
```sql
SELECT trip_date, trip_count, total_revenue
FROM staging.gold_daily_trips
ORDER BY trip_date;
```
**Time: 3 ms**

## Result

| Query | Time | Rows scanned |
|-------|------|--------------|
| Raw table | 2,463 ms | 3,066,766 |
| Gold mart | 3 ms | 36 |
| **Speedup** | **~800x** | **85,000x fewer rows** |

## Why this matters

The gold mart pre-aggregates the raw data at load time (via dbt incremental model).
Downstream BI tools and analysts query 36 rows instead of 3 million — the heavy
lifting happens once in the pipeline, not on every dashboard refresh.

At scale (12 months = ~36M rows), the raw query would take ~25 seconds.
The gold table stays at 3ms regardless of how much raw data grows.
