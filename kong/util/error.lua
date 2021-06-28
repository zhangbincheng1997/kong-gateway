return {
    jwt_error = {
        errcode = "jwt_error",
        errmsg = "jwt错误",
        status = 400,
    },
    iss_error = {
        errcode = "iss_error",
        errmsg = "iss错误",
        status = 400,
    },
    uid_error = {
        errcode = "uid_error",
        errmsg = "uid错误",
        status = 400,
    },
    redis_error = {
        errcode = "redis_error",
        errmsg = "redis错误",
        status = 400,
    },
    rate_limit = {
        errcode = "rate_limit",
        errmsg = "你的访问频率过快，请休息一会儿再来。",
        status = 200,
    },
}