i = 0
str1 = ""
str_start = """etcdctl put /apisix/routes/8 '{
    "host": "test-api.com",
    "uri": "/ip",
    "plugins": {
        "traffic-split": {
            "rules": [
            """
str_end = """
            ]
	}
    },
    "upstream": {
            "type": "roundrobin",
            "nodes": {
                "www.flask.com": 1
            }
    	}
	}'"""

for i in range(1):
	print(i)
	tmp_str = """{
	                    "match": [
	                        {
	                            "vars": [
	                                ["http_x-api-id","==",\"""" + str(i) + """"]
	                            ]
	                        }
	                    ],
	                    "weighted_upstreams": [
	                        {
	                            "upstream": {
	                                "name": "upstream-A",
	                                "type": "roundrobin",
	                                "nodes": {
	                                    "httpbin.org:80": """ + str(1) + """
	                                }
	                            },
	                            "weight": 3
	                        }
	                    ]
	                },"""
	str1 = str1 + tmp_str.replace(" ", "").replace(" ", "").replace(" ", "").replace("\n", "").replace("\t", "")


str1 = str1[:-1]
final_str = str_start + str1 + str_end

#print(str1)
with open("json_text", "w") as f:
	f.write(final_str.replace("\n", "").replace("\t", ""))
