
local function monitor_init()
    prometheus = require("prometheus").init("prometheus_metrics")
    metric_requests = prometheus:counter(
       "nginx_http_requests_total", "Number of HTTP requests", {"uri", "status", "task", "appid"})
    filter_requests = prometheus:counter(
       "nginx_filter_requests_total", "Number of filter requests", {})   
end

monitor_init()

