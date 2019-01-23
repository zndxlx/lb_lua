local task_model = require("task_model")
local cjson = require("cjson.safe")
local roundrobin = require "resty.roundrobin"
local task_view = require("task_view")
local utils = require("app.libs.utils")

local task_cache = {}


local function load_task(premature, self)
    if not premature then
        local tasks_cfg, err = task_model:query_valid()
        if err ~= nil then
            ngx.log(ngx.ERR, "failed to get task cfg: ", err)
        else 
            ngx.log(ngx.INFO, "get valid task:  ", cjson.encode(tasks_cfg))
            self:update(tasks_cfg)
        end
    end
end

local function check(premature, self)
    if not premature then
        --更新task view数据到数据库
        for key, task in pairs(self.tasks) do
            if task ~= nil then
                local views = task_view:get(task.id)
                task_model:update(task.id, {times_finish=views})
            end
        end        
        
        local tasks_cfg, err = task_model:query_valid()
        if err ~= nil then
            ngx.log(ngx.ERR, "failed to get task cfg: ", err)
        else 
            ngx.log(ngx.INFO, "get valid task:  ", cjson.encode(tasks_cfg))
            self:update(tasks_cfg)
        end
    end
end

function task_cache:work_init()
    self.tasks = nil
    self.servers = nil
    self.rr = nil
    local ok, err = ngx.timer.at(0, load_task, self)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end   
    
    local ok, err = ngx.timer.every(60, check, self)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end     
end


function task_cache:get_tasks()
    ngx.log(ngx.INFO, "get all task  ", cjson.encode(self.tasks))
    return self.tasks
end

function task_cache:get_task(id)
    ngx.log(ngx.INFO, "id ", id,  ", task ", cjson.encode(self.tasks[id]))
    return self.tasks[id]
end


function task_cache:round()
    if self.rr == nil or self.tasks == nil then
        ngx.log(ngx.ERR, "no  task ")
        return nil
    end
    
    local id = self.rr:find()
    
    return id
end

function task_cache:update(tasks_cfg)
    ngx.log(ngx.INFO, "task cfg ", cjson.encode(tasks_cfg))
    
    self.rr = nil
    self.tasks = {}
    self.servers = {}
    
    if #tasks_cfg == 0 then
        ngx.log(ngx.INFO, "no cfg")
        return
    end
 
    weight_all = 0
    for key, task_cfg in pairs(tasks_cfg) do
        if task_cfg ~= nil then
            task_cfg.appid_set = {}
            if task_cfg.appids ~= nil and  task_cfg.appids:len() ~= 0 then
                appid_list = utils.string_split(task_cfg.appids, ",")
                for _, v in pairs(appid_list) do
                    task_cfg.appid_set[v] = true
                end
            end
            
            self.tasks[task_cfg.id] = task_cfg
            self.servers[task_cfg.id] = task_cfg.weight
            weight_all = weight_all + task_cfg.weight
        end
    end
    
    self.servers[-1] = 10000 - weight_all    -- -1认为是不需要处理
    
    self.rr = roundrobin:new(self.servers)
    
    ngx.log(ngx.INFO, "tasks  ", cjson.encode(self.tasks))
    ngx.log(ngx.INFO, "servers  ", cjson.encode(self.servers))
    
end

return task_cache
