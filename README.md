# NYC Taxi ETL Pipeline

A production-style batch ETL pipeline built on the NYC TLC Yellow Taxi dataset (~3M rows).
Demonstrates a full data engineering stack: ingestion, transformation, testing, orchestration, and documentation.

## What this builds

| Layer | Model | Description |
|-------|-------|-------------|
| Bronze | `raw.taxi_trips` | Raw Parquet loaded as-is into Postgres |
| Silver | `stg_taxi_trips` | Typed, cleaned, renamed columns + derived fields |
| Gold | `gold_daily_trips` | Daily trips, revenue, avg fare — incremental table |
| Gold | `gold_zone_demand` | Trip volume per pickup zone, ranked |
| Gold | `gold_peak_hours` | Trip count and avg metrics by hour of day |
| Gold | `gold_anomaly_trips` | 7-flag anomaly detection (negative duration, >3hrs, >100mi, zero fare, high fare, zero/excess passengers) |

## Results

- **18/18 data quality tests passing** across all models
- **800x query speedup**: daily aggregation on gold mart runs in 3ms vs 2,463ms on raw table
- Full pipeline (ingest → dbt run → dbt test) orchestrated with **Prefect 3** and **Apache Airflow**
- Anomaly detection model flags 7 data quality conditions across ~3M rows

## Stack

| Tool | Purpose |
|---|---|
| PostgreSQL 15 | Data warehouse (Docker) |
| dbt 1.7 | Transformation, testing, and anomaly detection |
| Prefect 3 | Primary pipeline orchestration |
| Apache Airflow | Airflow DAG (alternative orchestrator) |
| Python 3.11 | Ingestion script (pandas + SQLAlchemy) |
| GitHub Actions | CI — dbt run + test on every push |

## How to run

### 1. Start Postgres
```bash
docker compose -f docker/docker-compose.yml up -d
```

### 2. Set up dbt connection
```bash
cp warehouse/dbt_taxi/profiles.yml.example ~/.dbt/profiles.yml
# Edit ~/.dbt/profiles.yml with your credentials
```

### 3. Run the full pipeline
```bash
pip3 install prefect dbt-postgres pandas pyarrow sqlalchemy
python3 orchestration/pipeline.py
```

### 4. Run dbt only (data already loaded)
```bash
cd warehouse/dbt_taxi
dbt deps
dbt run
dbt test
```

### 5. Browse dbt docs
```bash
cd warehouse/dbt_taxi
dbt docs generate && dbt docs serve
```

## Project structure

```
├── src/ingest_raw.py          # Downloads Parquet and loads into raw.taxi_trips
├── warehouse/dbt_taxi/        # dbt project
│   ├── models/staging/        # Silver layer — stg_taxi_trips
│   └── models/marts/          # Gold layer — daily, zone, peak hour KPIs
├── orchestration/pipeline.py  # Prefect flow: ingest → dbt run → dbt test
└── docs/
    ├── architecture.md        # Pipeline design and data flow
    └── benchmarks.md          # Raw vs gold query performance results
```

## Key findings

- `payment_type = 0` appears in 71k rows — undocumented in NYC TLC spec but
  behaves like credit card (avg tip $3.73). Documented and included in tests.
- Data contains outlier rows dated as far back as 2008 — retained in gold tables
  to preserve data fidelity.
