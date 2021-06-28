local json = require "cjson"

local response = {}

function response:err(error, detail)
    local status = error["status"] or 200
    local body = {
        errcode = error["errcode"] or "Unknown",
        errmsg = error["errmsg"] or "未知错误",
        detail = detail or "",
    }
    local body_str = json.encode(body)
    local header = {
        ["Content-Type"] = "application/json; charset=utf-8"
    }
    kong.response.exit(status, body_str, header)
end

function response:ok(data)
    local body = {
        errcode = 0,
        errmsg = "ok",
        data = data,
    }
    local body_str = json.encode(body)
    local header = {
        ["Content-Type"] = "application/json; charset=utf-8"
    }
    kong.response.exit(200, body_str, header)
end

return response