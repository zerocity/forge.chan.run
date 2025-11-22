"""
Tests for the example_hello_world DAG

These tests validate DAG structure without requiring database initialization.
"""

from airflow.models import DagBag


def test_dag_loaded():
    """Test that the DAG is properly loaded without import errors"""
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)
    assert "example_hello_world" in dag_bag.dags
    assert len(dag_bag.import_errors) == 0


def test_dag_structure():
    """Test the structure of the DAG"""
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)
    dag = dag_bag.dags.get("example_hello_world")

    assert dag is not None
    assert len(dag.tasks) == 1
    assert dag.tasks[0].task_id == "say_hello"


def test_dag_configuration():
    """Test DAG configuration"""
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)
    dag = dag_bag.dags.get("example_hello_world")

    assert dag is not None
    assert dag.catchup is False
    assert dag.default_args["owner"] == "airflow"
    assert dag.default_args["retries"] == 1
    assert "example" in dag.tags
    assert "hello_world" in dag.tags


def test_hello_world_task_function():
    """Test the hello_world task function executes without errors"""
    from dags.example_hello_world import hello_world

    result = hello_world()
    assert result == "Success"
