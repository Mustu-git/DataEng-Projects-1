# Pipeline Architecture

## Overview

A production-style batch ETL pipeline that ingests NYC TLC Yellow Taxi data,
transforms it through a medallion architecture using dbt, and serves gold-layer
KPI tables optimized for analytics queries.

## Data Flow

```
NYC TLC Parquet (S3)
        │
        ▼
[ src/ingest_raw.py ]
  Download + load into Postgres
        │
        ▼
  raw.taxi_trips
  (3M rows, original column names)
        │
        ▼
[ dbt staging ]
  stg_taxi_trips
  - Cast types
  - Rename columns (tpep_* → pickup_ts etc.)
  - Derive trip_duration_mins, is_weekend
        │
        ▼
[ dbt marts ]
  ┌─────────────────────┐
  │ gold_daily_trips     │  ← incremental table
  │ gold_zone_demand     │  ← view
  │ gold_peak_hours      │  ← view
  └─────────────────────┘
        │
        ▼
  Analytics / BI tools
```

## Medallion Layers

| Layer | Schema | Description |
|-------|--------|-------------|
| Bronze | `raw` | Raw Parquet loaded as-is, no transformations |
| Silver | `staging` | Typed, cleaned, renamed columns + derived fields |
| Gold | `staging` | Pre-aggregated KPI tables optimized for fast queries |

## Orchestration

Prefect 3 (`orchestration/pipeline.py`) runs the full pipeline in sequence:

1. **ingest-raw** — downloads Parquet and loads into `raw.taxi_trips`
2. **dbt-run** — builds all staging and mart models
3. **dbt-test** — runs 18 data quality tests across all models

Each step is a tracked Prefect task. If any step fails, the flow stops and
reports which task failed with full logs.

Run the pipeline:
```bash
python3 orchestration/pipeline.py
```

## Data Quality Tests (18 total)

- `not_null` on all key columns across staging and marts
- `unique` on date/zone/hour keys in gold tables
- `accepted_values` on `payment_type` (0–6, with 0 documented as legacy credit card)

## Key Design Decisions

- **Incremental model** for `gold_daily_trips` — only processes new dates on each run,
  avoiding full 3M row scans after initial load
- **`skip_ingest` flag** in pipeline — allows re-running dbt transforms without
  re-downloading the Parquet file
- **profiles.yml outside repo** — credentials never committed to git
