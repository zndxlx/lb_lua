
local function stat()
    metric_requests:inc(1, {ngx.var.uri, ngx.var.status, ngx.var.task, ngx.var.appid})
end


stat()






