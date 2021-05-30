local global_config = require "kong.const.const"

local CustomHandler = {
    VERSION  = "1.0.0",
    PRIORITY = 10
}

-- 在每个 Nginx 工作进程启动时执行
function CustomHandler:init_worker()
    -- Implement logic for the init_worker phase here (http/stream)
    kong.log("init_worker")
end

-- Stream Module is used for Plugins written for TCP and UDP stream connections
--function CustomHandler:preread(config)
--    -- Implement logic for the preread phase here (stream)
--    kong.log("preread")
--end

-- 在SSL握手阶段的SSL证书服务阶段执行
function CustomHandler:certificate(config)
    -- Implement logic for the certificate phase here (http/stream)
    kong.log("certificate")
end

-- 从客户端接收作为重写阶段处理程序的每个请求执行。在这个阶段，无论是API还是消费者都没有被识别，因此这个处理器只在插件被配置为全局插件时执行
function CustomHandler:rewrite(config)
    -- Implement logic for the rewrite phase here (http)
    kong.log("rewrite")
end

-- 为客户的每一个请求而执行，并在它被代理到上游服务之前执行
function CustomHandler:access(config)
    -- Implement logic for the rewrite phase here (http)
    kong.log("access")

    if config.skip_auth then
        local body = "{\"Code\":\"200\",\"Msg\":\"skip_auth = false\"}"
        kong.response.exit(200, body, { ["Content-Type"] = "application/json; charset=utf-8" })
        return
    end

    local query_secret = kong.request.get_query_arg("secret")
    local secret = global_config.secret
    if query_secret == secret then
        local body = "{\"Code\":\"200\",\"Msg\":\"skip_auth = true\"}"
        kong.response.exit(200, body, { ["Content-Type"] = "application/json; charset=utf-8" })
        return
    end

    local body = "{\"ErrorCode\":\"50000\",\"ErrorMsg\":\"密钥错误！\"}"
    kong.response.exit(200, body, { ["Content-Type"] = "application/json; charset=utf-8" })
end

-- 从上游服务接收到所有响应头字节时执行
function CustomHandler:header_filter(config)
    -- Implement logic for the header_filter phase here (http)
    kong.log("header_filter")
end

-- 从上游服务接收的响应体的每个块时执行。由于响应流回客户端，它可以超过缓冲区大小，因此，如果响应较大，该方法可以被多次调用
function CustomHandler:body_filter(config)
    -- Implement logic for the body_filter phase here (http)
    kong.log("body_filter")
end

-- 当最后一个响应字节已经发送到客户端时执行
function CustomHandler:log(config)
    -- Implement logic for the log phase here (http/stream)
    kong.log("log")
end

-- return the created table, so that Kong can execute it
return CustomHandler
