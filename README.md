# kong-gateway

> 参考链接：https://github.com/qianyugang/kong-docs-cn

## Windows10安装Docker

[菜鸟教程](https://www.runoob.com/docker/windows-docker-install.html)

## 打包镜像
```
docker build -f Dockerfile -t kong-gateway .
 
build参数：
-f docker配置文件
-t 镜像名称
. 上下文环境的目录
```

## 网关安装
1. 创建环境

```
docker network create kong-net
```

2. 启动数据库

```
docker run -d --name kong-database \
     --network=kong-net \
     -p 5432:5432 \
     -e "POSTGRES_DB=kong" \
     -e "POSTGRES_USER=kong" \
     -e "POSTGRES_PASSWORD=kong" \
     postgres:9.6

// 换行
docker run -d --name kong-database --network=kong-net -p 5432:5432 -e "POSTGRES_DB=kong" -e "POSTGRES_USER=kong" -e "POSTGRES_PASSWORD=kong" postgres:9.6
```

3. 初始化数据库

```
docker run --rm \
     --network=kong-net \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=kong-database" \
     -e "KONG_PG_USER=kong" \
     -e "KONG_PG_PASSWORD=kong" \
     kong:latest kong migrations bootstrap

// 换行
docker run --rm --network=kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PG_USER=kong" -e "KONG_PG_PASSWORD=kong" kong:latest kong migrations bootstrap
```

4. 启动kong

```
docker run -it -d --name kong \
     --network=kong-net \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=kong-database" \
     -e "KONG_PG_USER=kong" \
     -e "KONG_PG_PASSWORD=kong" \
     -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
     -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
     -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
     --env "KONG_PLUGINS=bundled,api-access-gateway" \
     --env "KONG_LUA_PACKAGE_PATH=./?.lua;./?/init.lua;/data/kong/?.lua;" \
     -v D:\\kong-gateway:/data/kong \
     -p 8000:8000 \
     -p 8443:8443 \
     -p 127.0.0.1:8001:8001 \
     -p 127.0.0.1:8444:8444 \
     kong-gateway

// 换行
docker run -it -d --name kong --network=kong-net -e "KONG_DATABASE=postgres" -e "KONG_PG_HOST=kong-database" -e "KONG_PG_USER=kong" -e "KONG_PG_PASSWORD=kong" -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" -e "KONG_PROXY_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" --env "KONG_PLUGINS=bundled,api-access-gateway" --env "KONG_LUA_PACKAGE_PATH=./?.lua;./?/init.lua;/data/kong/?.lua;" -v D:\\kong-gateway:/data/kong -p 8000:8000 -p 8443:8443 -p 127.0.0.1:8001:8001 -p 127.0.0.1:8444:8444 kong-gateway

// -it参数表示伪终端，-d参数表示后台运行
// D:\\kong-gateway 修改为本地路径
```
访问：http://localhost:8001/

5. 启动konga

```
docker run -d --name konga \
     --network=kong-net \
     -e "DB_ADAPTER=postgres" \
     -e "DB_URI=postgresql://kong:kong@kong-database:5432/konga" \
     -p 1337:1337 \
     pantsel/konga

// 换行
docker run -d --name konga --network kong-net -e "DB_ADAPTER=postgres" -e "DB_URI=postgresql://kong:kong@kong-database:5432/konga" -p 1337:1337 pantsel/konga
```
访问：http://localhost:1337/

6. docker界面

![](docs/docker.png)

## 网关配置

0. 登录/注册

![](docs/register.png)

1. 创建连接Connection

![](docs/connection.png)

2. 创建服务Services

- 命令方式：
```
curl -i -X POST \
--url http://localhost:8001/services \
--data 'name=baidu-service' \
--data 'url=https://www.baidu.com/'
```

- 图形方式：

![](docs/service-1.png)

![](docs/service-2.png)

3. 创建路由Routes

- 命令方式：
```
curl -i -X POST \
--url http://localhost:8001/services/baidu-service/routes \
--data 'paths[]=/api/baidu'
```

- 图形方式：

![](docs/route-1.png)

![](docs/route-2.png)

4. 创建插件Plugins

- 命令方式：
```
curl -i -X POST \
--url http://localhost:8001/routes/e72acd4e-3f72-4075-afe3-60e77a09a932/plugins \
--data '{"name":"api-access-gateway","config":{"skip_auth":true}}' \
```

- 图形方式：

![](docs/plugin-1.png)

![](docs/plugin-2.png)

5. 网关测试

- [JWT](https://jwt.io/)

![](docs/jwt.png)

```
TestToken

{
  "iss": "roro",
  "uid": 2021314
}

eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJyb3JvIiwidWlkIjoyMDIxMzE0fQ.SGv-R0BWv6rYzYW9i-ZvfxNZbOygNGirRxHUoncIEMQ
```

- skip_auth = true

![](docs/test-1-1.png)

![](docs/test-1-2.png)

- skip_auth = false

![](docs/test-2-1.png)

![](docs/test-2-2.png)

![](docs/test-2-3.png)

- rate_limit

```lua
local function lock(uid)
    -- 连接池
    local red = redis:new(global_config.redis)
    -- NX SET if Not eXists
    -- EX 过期时间，seconds
    -- 成功：ok，失败：nil
    local ok, err = red:set(uid, 1, "NX", "EX", global_config.redis.expire_time or 10)
    kong.log(ok, err)
    if err then
        return response:err(error.redis_error, err)
    end
    if not ok then
        return response:err(error.rate_limit)
    end
end
```

![](docs/test-3-1.png)

![](docs/test-3-2.png)

## 插件开发

[Plugin Development - Implementing Custom Logic](https://docs.konghq.com/gateway-oss/2.4.x/plugin-development/custom-logic/)

[实现自定义逻辑](https://github.com/qianyugang/kong-docs-cn/blob/master/GUIDES%26REFERENCES/plugin-development/custom-logic.md)

[Plugin Development - Plugin Configuration](https://docs.konghq.com/gateway-oss/2.4.x/plugin-development/plugin-configuration/)

[插件配置](https://github.com/qianyugang/kong-docs-cn/blob/master/GUIDES&REFERENCES/plugin-development/plugin-configuration.md)
