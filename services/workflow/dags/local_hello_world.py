"""
Example DAG: Hello World

This is a simple example DAG that demonstrates the basic structure of an Airflow DAG.
It runs a simple Python task that prints "Hello World" to the logs.

Schedule: Daily at midnight
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator


def hello_world():
    """Simple task that prints Hello World"""
    print("Hello World from local Airflow!")
    print(f"Execution date: {datetime.now()}")
    return "Success"


# Default arguments for the DAG
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "start_date": datetime(2024, 1, 1),
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

# Define the DAG
with DAG(
    "local_hello_world",
    default_args=default_args,
    description="A simple Hello World DAG",
    schedule=timedelta(days=1),
    catchup=False,
    tags=["local"],
) as dag:
    # Define the task
    hello_task = PythonOperator(
        task_id="say_hello",
        python_callable=hello_world,
    )

    # Task dependencies (none in this simple example)
    hello_task
