# install python3.7
# https://github.com/Revolution1/etcd3-py
from etcd3 import Client
import json
import string
import random


def connect():
    try:
        client = Client('127.0.0.1', 2379)
        print(client.version())
        return client
    except Exception as e:
        print(str(e))

def get_key(client, key):
    # get key
    val = client.range(key).kvs[0].value.decode("utf-8")
    return val

def get_access_keys():
    body = {"access_key": "ABCD", "backend_url": "www.google.com:80"}
    body_json = json.loads(body)
    access_key = body_json["access_key"]
    backend_url = body_json["backend_url"]
    return access_key, backend_url

def insert_keys():
    print("Establish Connection")

    try:
        final_key = {}
        N = 10
        client = connect()

        for i in range(1000):
            key = ''.join(random.choices(string.ascii_uppercase + string.digits, k=N))
            backend_url = "httpbin.org:80" + str(key)
            final_key[key] = backend_url

        print("Final key")
        print(str(final_key))
        client.put('/apisix/keys/all', str(final_key))
    except Exception as e:
        print(str(e))

if __name__ == "__main__":
    insert_keys()

# def test():
#         from etcd3 import Client
#         client = Client('127.0.0.1', 2379)
#         client.version()
#         key = ""
#
#         for i in range(10000000):
#                 key = key + "-test_key"
#         try:
#                 print("Insert key: " + str(i) + " size of key: " + str(len(key)))
#                 # print(key)
#                 client.put('test_value', key)
#                 print("put complete")
#                 val = client.range('test_value').kvs
#                 print(val[0:10])
#         except Exception as e:
#                 print("exception: " + str(e))
