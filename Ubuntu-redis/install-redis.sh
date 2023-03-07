sudo apt-get install lua5.3 -y
luarocks install redis-lua
lua5.3 /vagrant/test-lua/test.lua





    2  luarocks
    3  luarocks install redis-lua
    4  apk install unzip
    5  yum install unzip
    6  apt
    7  apt-get
    8  apk
    9  apk  add unzip
   10  luarocks install redis-lua
   11  apk add gcc
   12  luarocks install redis-lua
   13  apk add gcc++
   14  apk add gcc+
   15  apk add musl-dev
   16  ls
   17  cd apisix/
   18  ls
   19  vim lua-redis.lua
   20  apk add vim
   21  vim lua-redis.lua
   22  lua lua-redis.lua
   23  apk install lua
   24  apk add lua
   25  apk install lua
   26  lua lua-redis.lua
   27  luarocks install redis-lua
   28  apk add md5sum
   29  apk add md5
   30  apk add openssl
   31  luarocks install redis-lua
   32  history





local redis_new = require("resty.redis").new
local red = redis_new()
local ok, err = red:connect(10.0.2.2, 6379)
print("Redis conn", ok)