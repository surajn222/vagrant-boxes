#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

"""Example DAG demonstrating the usage of the BashOperator."""

import datetime

import pendulum

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator

TABLE_NAME = "test1"
TABLE_NAME = '{{dag_run.conf["table_name"] if dag_run else "TABLE_NAME"}}'

OG_TABLE_NAME = "OG_TABLE"

TABLE_NAME = '{{ dag_run.conf["cli_test2"] if dag_run.conf else }}' + OG_TABLE_NAME

with DAG(
    dag_id='example_bash_operator_custom',
    schedule_interval='0 0 * * *',
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),
    catchup=False,
    dagrun_timeout=datetime.timedelta(minutes=60),
    tags=['example', 'example2'],
    params={"example_key": "example_value"},
) as dag:
    run_this_last = EmptyOperator(
        task_id='run_this_last',
    )

    # [START howto_operator_bash]
    run_this = BashOperator(
        task_id='run_after_loop',
        bash_command='echo ' + TABLE_NAME,
    )
    # [END howto_operator_bash]

    get_var_filename = BashOperator(
        task_id="get_var_filename2",
        bash_command='echo "You are running this DAG with the following variable file: \'{{ dag_run.conf["cli_test2"] if dag_run.conf else "" }}\'"',
    )

    get_var_filename_custom = BashOperator(
        task_id="get_var_filename_custom",
        bash_command='echo "You are running this DAG with the following variable file: "' + TABLE_NAME,
    )

    get_var_filename_custom
    # get_var_filename
    # run_this >> run_this_last


if __name__ == "__main__":
    dag.cli()