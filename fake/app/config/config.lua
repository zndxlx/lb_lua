local Config={}

Config.redis = {
    host = '192.168.8.237',
    port = '6379',
    password = ''
}



Config.mysql = {
    timeout = 5000,
    connect_config = {
        host = "192.168.8.237",
        port = 3306,
        database = "test",
        user = "lebocloud",
        --password = "lebocloud",
        max_packet_size = 1024 * 1024,
        charset = "utf8"
    },
    pool_config = {
        max_idle_timeout = 20000, -- 20s
        pool_size = 50 -- connection pool size
    }
}



Config.cache_time = 30

Config.version = '0.1'

return Config