# install python3.7
# https://github.com/Revolution1/etcd3-py
from etcd3 import Client
import json

def connect():
    try:
        client = Client('127.0.0.1', 2379)
        # print(client.version())
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

import time

def insert_keys():
    # establish connection
    print("Establish Connection")

    list_time = []
    for i in range(1):
        try:
            start = time.time()
            client = connect()
            value = get_key(client, '/apisix/keys/ZYLVGZFL9K')
            #json_val = json.loads(str(value).replace("'", "\""))
            #print(str(json_val))
            print(value)
            end = time.time()

            time_taken = end-start
            #print("Time: " + str(time_taken))
            list_time.append(time_taken)
        except Exception as e:
            print(str(e))

    print("Max: " + str(max(list_time)))
    print("Min: " + str(min(list_time)))
    print("Avg: " + str(sum(list_time)/len(list_time)))

    # alter key

    # add to database again

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


# 1000 keys
# Max: 0.03376197814941406
# Min: 0.008998632431030273
# Avg: 0.017252581119537355


# 1000000 keys
# Max: 0.0400543212890625
# Min: 0.011472702026367188
# Avg: 0.018202006816864014

# Max: 0.04751181602478027
# Min: 0.009230375289916992
# Avg: 0.019019737243652343
