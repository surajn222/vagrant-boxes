from datetime import datetime
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.providers.microsoft.azure.hooks.wasb import WasbHook
from airflow.providers.amazon.aws.operators.s3_list import S3ListOperator
import sys
from wasb_hook_custom import WasbHookCustom
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from io import BytesIO
import boto3
import threading

def get_azure_conn():
    variable_account_name = "azure_blob_storage_account_name"
    variable_shared_key = "azure_blob_storage_shared_key"

    wasb_conn_id = "azure_blob_storage"
    wasb_hook = WasbHookCustom(variable_account_name, variable_shared_key)

    return wasb_hook


def list_azure_files(wasb_hook, container_name, prefix):
    from datetime import datetime

    # current_datetime = datetime.now()
    # current_year = current_datetime.date().year
    # current_month = current_datetime.date().month
    # current_date = current_datetime.time().day
    # current_hour = current_datetime.time().hour

    # container_name = "surajetlexport0"
    #
    include = None
    delimiter = "/"

    # list_blobs = wasb_hook.get_blobs_list(container_name, prefix, include, delimiter)
    # print("List blobs:")
    # print(list_blobs)

    print("Walk blob")
    list_blobs = wasb_hook.walk_container(container_name, prefix)
    print(list_blobs)

    # wasb_hook.load_file(
    #     tmp_path,
    #     container_name=rankings_container,
    #     blob_name=f"{year}/{month:02d}.csv",
    # )

    return list_blobs


def upload_file_S3():
    print("Upload file")
    s3_file = S3ListOperator(
        task_id='azure_blob_test',
        bucket='test-bucket-suraj',
        prefix='',
        delimiter='/',
        aws_conn_id='aws_s3',
        dag = dag
    )

    print("S3 files")
    print(type(s3_file))
    print(s3_file.output)


def download_and_upload(azure_hook, s3_client, filename):
    container_name = 'surajetlexport0'

    acc_url = "https://.blob.core.windows.net/"
    token = ""

    blob_service_client = BlobServiceClient(
        account_url=acc_url,
        credential=token
    )

    # container_client = blob_service_client.get_container_client(container=container_name)
    # blob_client = container_client.get_blob_client(filename)
    stream = wasb_hook.get_blob_bytes()

    # stream = BytesIO()
    # streamdownloader.download_to_stream(stream)

    print("Stream download completed")
    #print(stream)

    print("Uploading to s3")
    #stream.seek(0)  # Without this line it fails
    s3_client.put_object(Bucket="suraj-testbucket-2",
                           Key=filename,
                           Body=stream)

    print("Uploading to s3 completed")

    return True



def download_upload_hook(wasb_hook, s3_client, container_name, file_name):
    stream = wasb_hook.get_blob_bytes(container_name, file_name)
    print("Stream download completed")
    print("Uploading to s3")
    # s3_client.put_object(Bucket="suraj-testbucket-2",
    #                        Key=filename,
    #                        Body=stream)
    #
    # print("Uploading to s3 completed")




def upload_multithreaded(list_blobs):
    threads = list()
    #Get the list of the blobs here
    for blob in list_blobs:
        print("Main : create and start thread %d.", blob)
        x = threading.Thread(target=download_file_bytes, args=(blob, ))
        threads.append(x)
        x.start()

    for index, thread in enumerate(threads):
        print("Main    : before joining thread %d.", index)
        thread.join()
        print("Main    : thread %d done", index)

def upload_multithreaded_limit(azure_hook, s3_client, container_name, list_blobs):
    count = 0
    maxthreads = 50

    while True and count < len(list_blobs):
        if threading.activeCount() < maxthreads:
            worker = threading.Thread(target=download_upload_hook, args=(azure_hook, s3_client, container_name, list_blobs[count],))
            worker.start()
            worker.join()
            count += 1
import boto3
def get_s3_client():
    s3_client = boto3.client('s3',
                             aws_access_key_id="",
                             aws_secret_access_key="",
                             region_name="us-east-1"
                             )
    
    
    
    return s3_client

def list_s3_files(s3_client, location):
    list_files = []
    bucket_name = location.split("/", 1)[0]
    prefix = location.split("/", 1)[1]
    response = s3_client.list_objects(Bucket=bucket_name, Prefix=prefix)
    for content in response.get('Contents', []):
        if content.get('Key')[-1] != "/":
            print(content.get('Key').split("/", 1)[1])
            list_files.append(content.get('Key').split("/", 1)[1])

    return list_files

def get_azure_blob_location():
    from datetime import datetime

    current_datetime = datetime.now()
    current_year = current_datetime.date().year
    current_month = current_datetime.date().month
    current_date = current_datetime.date().day
    current_hour = current_datetime.time().hour

    location = f"surajetlexport0/schema/surajetl_export003/"

    return location

def copy_blob_to_s3():
    azure_hook = get_azure_conn()
    s3_client = get_s3_client()

    #azure_blob_location = get_azure_blob_location()
    azure_blob_location = "surajetlexport0/schema/surajetl_"
    container_name = azure_blob_location.split("/", 1)[0]
    azure_prefix = azure_blob_location.split("/", 1)[1]

    s3_location = "suraj-testbucket-2/surajetl"

    print(azure_blob_location)
    print(s3_location)

    azure_blobs = list_azure_files(azure_hook, container_name, azure_prefix)
    print("Azure blobs")
    print(azure_blobs)

    s3_files = list_s3_files(s3_client, s3_location)
    print("s3 objects")
    print(s3_files)

    list_files_to_copy = set(azure_blobs) - set(s3_files)
    print("List of files to copy")
    print(list(list_files_to_copy))

    upload_multithreaded_limit(azure_hook, s3_client, container_name, azure_blobs)



#Dag definitions
dag = DAG('azure_blob_test', description='Azure Test',schedule_interval='0 12 * * *',start_date=datetime(2017, 3, 20), catchup=False)

azure_operator = PythonOperator(task_id='azure_blob_test', python_callable=copy_blob_to_s3, dag=dag)

s3_operator = S3ListOperator(
        task_id='s3_bucket_list_files',
        bucket='test-bucket-suraj',
        prefix='',
        delimiter='/',
        aws_conn_id='aws_s3',
        dag = dag
    )

azure_operator



