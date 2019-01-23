local task_cache = require("task_cache")
local req_counter = ngx.shared.req_counter

--更新qps限制
local function cal_limit(premature)
    if not premature then
        ngx.log(ngx.ERR, "+++++++++++++++=== cal_limit ")
        local now = ngx.now() - ngx.now() % 1
        local key = now - 1
        local counter = 0
        local index = 0
        
        for var = 1,600 do  
            local v = req_counter:get(key)
            if v ~= nil then
                ngx.log(ngx.INFO, "cal_limit key: ", key, ",v:", v)
                counter = counter + v
                index = index + 1
            end
            key = key - 1
        end 
        
        if index < 60 then
            ngx.log(ngx.INFO, "few key in cache")
        else
            local req_avg = math.modf(counter/index)
            if req_avg == 0 then
                req_avg = 1
            end
            ngx.log(ngx.INFO, "cal_limit counter: ", counter, ",index:", index, ",req_avg:", req_avg)
            req_counter:set("qps_limit", req_avg)
        end
    end
end

local function  limit_task_init() 
    if 0 == ngx.worker.id() then
        local ok, err = ngx.timer.every(10, cal_limit)
        if not ok then
            ngx.log(ngx.ERR, "failed to create timer: ", err)
            return
        end   
    end
end


local function work_init()
    task_cache:work_init()
    limit_task_init()
    return
end


work_init()







