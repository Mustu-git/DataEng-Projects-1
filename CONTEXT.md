# Project Context — DataEng-Projects-1

## Portfolio Goal
4-project data engineering portfolio demonstrating end-to-end DE skills.

---

## Project 1 — NYC Taxi Parquet Lakehouse (CURRENT — nearly complete)
**Purpose:** Large Parquet data end-to-end → analytics-ready tables.

### Stack
- Postgres 15 in Docker — `localhost:5433`, db: `taxi_db`, user: `taxi_user`, pass: `taxi_pass`
- dbt 1.11.7 (dbt-postgres 1.10.0), Python 3.11, Prefect 3
- Repo: https://github.com/Mustu-git/DataEng-Projects-1

### Repo layout
```
~/DataEng-Projects-1/
├── src/ingest_raw.py                  ✅ loads Parquet → raw.taxi_trips (3M rows)
├── warehouse/dbt_taxi/                ✅ dbt project (profile: dbt_taxi)
│   ├── models/staging/
│   │   ├── sources.yml                ✅ points to raw schema
│   │   ├── stg_taxi_trips.sql         ✅ casts, renames, trip_duration_mins, is_weekend
│   │   └── stg_taxi_trips.yml         ✅ 18/18 tests passing
│   └── models/marts/
│       ├── gold_daily_trips.sql       ✅ incremental table — daily trips/revenue/avg fare
│       ├── gold_zone_demand.sql       ✅ trips per pickup zone ranked (view)
│       ├── gold_peak_hours.sql        ✅ trips by hour of day (view)
│       └── gold_anomaly_trips.sql     ⬜ not started
├── orchestration/pipeline.py          ✅ Prefect: ingest → dbt run → dbt test
├── docker/docker-compose.yml          ⬜ missing — needs to be created
└── docs/
    ├── architecture.md                ✅ full pipeline diagram
    └── benchmarks.md                  ✅ 800x speedup raw vs gold
```

### Key data notes
- Raw columns: `tpep_pickup_datetime`, `tpep_dropoff_datetime`, `PULocationID`, `DOLocationID`
- `payment_type = 0` exists (71k rows) — undocumented, behaves like credit card
- Data has outlier rows from 2008 — retained intentionally
- Raw query: 2,463ms | Gold mart query: 3ms (~800x speedup)

### What's left for Project 1
- `gold_anomaly_trips` model — outlier/anomaly trips
- `docker/docker-compose.yml` — so anyone can spin up the DB from scratch
- Optionally: materialize `gold_zone_demand` and `gold_peak_hours` as tables

### How to run
```bash
cd ~/DataEng-Projects-1/warehouse/dbt_taxi
dbt run       # build all models
dbt test      # run all 18 tests
dbt docs generate && dbt docs serve
python3 orchestration/pipeline.py  # full Prefect pipeline
```

---

## Project 2 — Data Quality + Observability Layer (NOT STARTED)
**Purpose:** Production-like quality gates and monitoring.
**Outputs:** `dq_run_results`, `dq_table_freshness`, `dq_rowcount_drift`, `schema_snapshots`
**Skills:** data testing strategy, schema drift, freshness/drift checks, monitoring mindset, runbooks

---

## Project 3 — API Ingestion Framework (NOT STARTED)
**Purpose:** Ingest from real APIs with pagination, rate limits, incremental sync.
**Outputs:** raw JSON bronze storage, cleaned silver tables, gold metrics
**Skills:** API auth, pagination, retries/backoff, incremental loading, idempotency, schema drift tolerance

---

## Project 4 — Kafka Streaming Replay + Aggregations (NOT STARTED)
**Purpose:** Streaming fundamentals using Kafka (replayed source).
**Outputs:** Kafka topics (raw/clean/agg/DLQ), windowed aggregates (events/min, anomalies)
**Skills:** Kafka design, dedup/DLQ, stream processing, operational thinking (lag/retries)
