"""
Prefect pipeline: ingest → dbt run → dbt test
Run with: python orchestration/pipeline.py
"""

import subprocess
import sys
from pathlib import Path

from prefect import flow, task, get_run_logger

REPO_ROOT = Path(__file__).parent.parent
DBT_DIR = REPO_ROOT / "warehouse" / "dbt_taxi"


@task(name="ingest-raw")
def ingest_raw():
    logger = get_run_logger()
    logger.info("Starting raw ingestion...")
    result = subprocess.run(
        [sys.executable, str(REPO_ROOT / "src" / "ingest_raw.py")],
        capture_output=True,
        text=True
    )
    logger.info(result.stdout)
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError(f"ingest_raw.py failed:\n{result.stderr}")
    logger.info("Raw ingestion complete.")


@task(name="dbt-run")
def dbt_run():
    logger = get_run_logger()
    logger.info("Running dbt models...")
    result = subprocess.run(
        ["dbt", "run"],
        cwd=DBT_DIR,
        capture_output=True,
        text=True
    )
    logger.info(result.stdout)
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError(f"dbt run failed:\n{result.stdout}")
    logger.info("dbt run complete.")


@task(name="dbt-test")
def dbt_test():
    logger = get_run_logger()
    logger.info("Running dbt tests...")
    result = subprocess.run(
        ["dbt", "test"],
        cwd=DBT_DIR,
        capture_output=True,
        text=True
    )
    logger.info(result.stdout)
    if result.returncode != 0:
        logger.error(result.stderr)
        raise RuntimeError(f"dbt test failed:\n{result.stdout}")
    logger.info("dbt test complete.")


@flow(name="taxi-etl-pipeline")
def taxi_pipeline(skip_ingest: bool = False):
    """
    Full ETL pipeline: ingest raw data → transform with dbt → validate with tests.
    Set skip_ingest=True to skip the download/load step (data already in DB).
    """
    if not skip_ingest:
        ingest_raw()
    dbt_run()
    dbt_test()


if __name__ == "__main__":
    # Pass skip_ingest=True since data is already loaded
    taxi_pipeline(skip_ingest=True)
