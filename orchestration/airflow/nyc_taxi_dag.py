"""
NYC Taxi ETL Pipeline — Airflow DAG

Mirrors the Prefect pipeline in orchestration/pipeline.py.
Run with: docker compose -f docker/docker-compose.yml up -d
then copy this file to your Airflow DAGs folder.

DAG order: ingest_raw >> dbt_run >> dbt_test
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = "/opt/airflow/dags/DataEng-Projects-1"
DBT_DIR     = f"{PROJECT_DIR}/warehouse/dbt_taxi"

default_args = {
    "owner": "mustafa",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": False,
}

with DAG(
    dag_id="nyc_taxi_pipeline",
    description="NYC Taxi ETL: ingest → dbt run → dbt test",
    schedule_interval="@daily",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["nyc_taxi", "etl", "dbt"],
) as dag:

    ingest_raw = BashOperator(
        task_id="ingest_raw",
        bash_command=f"cd {PROJECT_DIR} && python3 src/ingest_raw.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_DIR} && dbt run",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt test",
    )

    ingest_raw >> dbt_run >> dbt_test
