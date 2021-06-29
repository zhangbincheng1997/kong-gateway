local json = require "cjson"

local GlobalHandler = {
    VERSION  = "1.0.0",
    PRIORITY = 10000
}

-- 为客户的每一个请求而执行，并在它被代理到上游服务之前执行
function GlobalHandler:access(config)
    -- Implement logic for the rewrite phase here (http)
    local service = kong.router.get_service()
    kong.log("service : " .. json.encode(service))
end

-- 从客户端接收作为重写阶段处理程序的每个请求执行。在这个阶段，无论是API还是消费者都没有被识别，因此这个处理器只在插件被配置为全局插件时执行
function GlobalHandler:rewrite(config)
    -- Implement logic for the rewrite phase here (http)
    kong.log("rewrite")
end

return GlobalHandler
