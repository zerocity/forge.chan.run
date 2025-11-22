# Airflow DAGs Directory

This directory contains Apache Airflow DAG (Directed Acyclic Graph) definitions.

## Structure

```
dags/
├── __init__.py           # Python package initialization
├── example_hello_world.py # Simple example DAG
└── README.md             # This file
```

## Creating a New DAG

1. Create a new Python file in this directory
2. Import required modules:
   ```python
   from airflow import DAG
   from airflow.operators.python import PythonOperator
   from datetime import datetime, timedelta
   ```

3. Define your DAG:
   ```python
   with DAG(
       'my_dag_name',
       start_date=datetime(2024, 1, 1),
       schedule='@daily',
       catchup=False,
   ) as dag:
       # Define tasks here
       pass
   ```

4. Save the file - Airflow will automatically detect it

## Example DAGs

- `example_hello_world.py` - Simple Hello World task

## DAG Development Best Practices

1. **Use meaningful DAG IDs** - Make them descriptive and unique
2. **Set appropriate schedules** - Use cron expressions or timedelta
3. **Add tags** - Help organize and filter DAGs
4. **Document your DAGs** - Add docstrings and comments
5. **Test locally** - Run `airflow dags test <dag_id> <execution_date>`
6. **Use catchup=False** - Unless you need historical runs
7. **Set reasonable retries** - Don't retry forever
8. **Add task dependencies** - Use >> or << operators

## Useful Commands

```bash
# List all DAGs
docker exec forge-airflow airflow dags list

# Test a DAG
docker exec forge-airflow airflow dags test <dag_id> <date>

# Trigger a DAG manually
docker exec forge-airflow airflow dags trigger <dag_id>

# View DAG structure
docker exec forge-airflow airflow dags show <dag_id>
```

## Resources

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [DAG Writing Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)
- [Operators Reference](https://airflow.apache.org/docs/apache-airflow/stable/operators-and-hooks-ref.html)
