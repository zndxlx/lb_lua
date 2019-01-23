local redis = require("app.libs.redis")

local task_view = {}

function task_view:get_key(task)
    return string.format("task_view:%s", task)
end


--每个任务计数  设置超时时间为3天
function task_view:incr(task)
    local key = self:get_key(task)
    
    local red = redis:new()
   
    local ok, err = red:incr(key)  
    if not ok then  
        ngx.log(ngx.ERR, "incr err : ", err, ",key :", key)  
        return false      
    end 
    
    
    ok, err = red:expire(key, 60*60*24*3)  
    if not ok then  
        ngx.log(ngx.ERR, "expire failed: ", err,  ",key :", key)
        return false        
    end
    
    return true
end

function task_view:get(task)
    local key = self:get_key(task)
    
    local red = redis:new()
   
    local res, err = red:get(key)  
    if not res then  
        ngx.log(ngx.ERR, "incr err : ", err, ",key :", key)  
        return 0, res      
    end 
    
    
    ok, err = red:expire(key, 60*60*24*3)  
    if not ok then  
        ngx.log(ngx.ERR, "expire failed: ", err, ",key :", key)  
    end
    
    return tonumber(res), nils
end

return task_view