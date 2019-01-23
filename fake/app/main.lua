local cjson = require("cjson.safe")
local conf = require("app.config.config")
local task_view = require("task_view")
local task_cache = require("task_cache")
local task_model = require("task_model")
local decipher = require("decipher")
local utils = require("app.libs.utils")
local http = require ("resty.http")

local function get_args()
    local args = ngx.req.get_uri_args()
    if args.s ~= nil and args.v ~= nil then
        return decipher:decode(args.s)
    end
    
    return args 
end

local function gsub_process(m)
    --ngx.log(ngx.INFO, "m:", cjson.encode(m)) 
    local args = ngx.ctx.args
    if m[0] == "__tid__" then
        return  args.tid 
    elseif m[0] == "__u__" then
        return  args.u
    elseif m[0] == "__sc__" then
        return  args.sc
    elseif m[0] == "__hid__" then
        return  args.hid
    elseif m[0] == "__bssid__" then
        return  args.bssid
    elseif m[0] == "__ads__" then
        return  args.ads
    end  
end

local function process()
    filter_requests:inc(1, {})
    local task_id = task_cache:round()
    if task_id == nil then
        ngx.say("no task")
        return
    end
    
    if task_id == -1 then
        ngx.say("not hit")
        return
    end 
    
    local task = task_cache:get_task(task_id)
    if task == nil then
        ngx.say("no task info")
        return
    end
    
    local args = get_args()
    if args == nil then
        ngx.say("get args failed")
        return
    end
    
    ngx.ctx.args = args
    
    if args.hid == nil or args.hid:len() < 2 or args.hid:sub(1,1) ~= "1" then
        ngx.say("err hid format")
        return
    end   

    if args.sc == nil then
        ngx.say("no appid")
        return
    end

    -- ngx.log(ngx.INFO, "task  ", cjson.encode(task))
    -- ngx.log(ngx.INFO, "task.appid_set  ", cjson.encode(task.appid_set))
    -- ngx.log(ngx.INFO, "appid_set_empty=", utils.is_table_empty(task.appid_set), ", task.appid_set[args.sc]=", task.appid_set[args.sc])

    if utils.is_table_empty(task.appid_set) == false and task.appid_set[args.sc] ~= true then
        ngx.say("appid not match " .. args.sc)
        return
    end
    
    if string.len(task.url_report)  ~= 0 then 
        local ads_hash_str = args.hid .. args.u .. ngx.localtime()
        local ads = ngx.md5(ads_hash_str) 
        ngx.ctx.args.ads = ads
    
        local report_url, n, err = ngx.re.gsub(task.url_report, "__[a-zA-Z]+__", gsub_process, "i")
        --ngx.log(ngx.INFO, "newstr:", newstr) 
        if report_url == nil then
            return ngx.say("report_url gsub failed")
        end  
        
        local httpc = http.new()
        local res, err = httpc:request_uri(report_url, {
            method = "GET",
            keepalive_timeout = 3000,
            keepalive_pool = 100
          })
        if not res then
            ngx.say("failed to report: ", err)
            return
        end
    end
    
    if string.len(task.url_302)  ~= 0 then 
        local hash_mac = args.hid:sub(2)
        local newurl, n, err = ngx.re.gsub(task.url_302, "__mac__", hash_mac, "i")
        if newurl then 
            task_view:incr(task.id)
            ngx.var.rsp_location = newurl
            ngx.var.task = task_id
            ngx.var.appid = args.sc
            return ngx.redirect(newurl, ngx.HTTP_MOVED_TEMPORARILY)
        else
            return ngx.say("newurl gsub failed")
        end
    else
        task_view:incr(task.id)
        ngx.var.task = task_id
        ngx.var.appid = args.sc
        ngx.say("no need do 302,task:" .. task_id)
    end
            
    return 
end
 
process() 

