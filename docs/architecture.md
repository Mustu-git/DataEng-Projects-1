# Architecture (Draft)

## Data flow
Parquet (NYC TLC trips) → Raw table (`raw.taxi_trips`) → dbt staging (`stg_taxi_trips`) → dbt marts (`gold_*`)

## Zones
- **Raw (Bronze):** raw Parquet loaded as-is into `raw.taxi_trips`
- **Staging (Silver):** typed/cleaned columns + derived fields
- **Marts (Gold):** KPI tables optimized for analytics queries

## Orchestration (planned)
Airflow DAG will:
- ingest monthly partitions
- run `dbt run` + `dbt test`
- record run metadata and basic quality metrics
