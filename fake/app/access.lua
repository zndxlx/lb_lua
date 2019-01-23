--local limit_req = require "resty.limit.req"
local req_counter = ngx.shared.req_counter

local function get_qps_limit()
    local v = req_counter:get("qps_limit")
    if not v then
       return 5000    ---默认值设置一个比较大的值
    end
    return v
end

local function access_main()
    local key = ngx.now() - ngx.now() % 1     --按秒统计，
    local current_counter = req_counter:get(key)
    --ngx.log(ngx.INFO, "req_incr key: ", key)
    if not current_counter then
        current_counter = 1
        req_counter:set(key, 1, 60*10)   --共保存10分钟的数据
    else
        req_counter:incr(key, 1)
    end

    local qps_limit = get_qps_limit()
    
    --ngx.log(ngx.INFO, "1111111111 qps_limit: ", qps_limit, ",current_counter:", current_counter)

    if current_counter > qps_limit then
        ngx.say("qps limit")
        return ngx.exit(ngx.HTTP_OK)
    end

end

access_main()




