Data engineering portfolio. NYC TLC Parquet lakehouse with dbt models, data quality checks, and performance benchmarks.

## Project Goal
Build a production-style analytics pipeline on the NYC TLC Taxi Parquet dataset using dbt. The pipeline converts raw trip records into cleaned staging models and curated “gold” KPI tables, with automated data quality tests and performance benchmarking.

## What this repo produces
- **Staging model:** `stg_taxi_trips` (typed + cleaned trips, derived duration)
- **Gold KPI table:** `gold_daily_trips` (daily trips, revenue, averages)
- (Coming next) Additional gold tables: zone demand, peak hours, anomaly trips
- (Coming next) Orchestration with Airflow + optional warehouse publishing

## Skills showcased
- dbt modeling (sources, refs, staging → marts)
- Data quality testing (schema + KPI-level tests)
- Working with large Parquet datasets (partition/incremental-friendly design)
- Production mindset: reproducible repo structure, docs, and benchmarks
