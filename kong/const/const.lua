local GlobalConfig = {
    redis = {
        addr = "39.107.29.66",
        enabled_password = true,
        password = "cc123/.,",
        db = 0,
        expire_time = 10,
    },
    auth = {
        iss = "roro",
        token = "TestToken",
    },
    role = {
        ADMIN = 1,
        GUEST = 2,
    }
}

return GlobalConfig