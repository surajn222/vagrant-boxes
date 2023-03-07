# install python3.7
# https://github.com/Revolution1/etcd3-py
from etcd3 import Client
import json

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

def insert_keys(access_key, backend_url):
        # establish connection
        print("Establish Connection")

        try:
                client = connect()
                value = get_key(client, '/apisix/routes/1')
                json_val = json.loads(str(value))

                list_rules = json_val['plugins']['traffic-split']['rules']

                #access_key, backend_url = get_access_keys()
                new_rule = """{'weighted_upstreams': [{'upstream': {'hash_on': 'vars', 'name': 'upstream-C', 'pass_host': 'pass', 'nodes': {'""" + str(backend_url) + """': 1}, 'type': 'roundrobin', 'scheme': 'http'}, 'weight': 3}], 'match': [{'vars': [['http_x-api-id', '==', '""" + str(access_key) + """']]}]}"""
                list_rules.append(json.loads(new_rule.replace("'", "\"")))

                # Modify the key
                json_val['plugins']['traffic-split']['rules'] = list_rules
                json_val['id'] = 1

                print("KEY --------- ")
                final_key = str(json_val).replace(" ","").replace("/","\/").replace("'","\"")

                client.put('/apisix/routes/1', final_key)
        except Exception as e:
                print(str(e))

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
