local DB = require("app.libs.db")
local db = DB:new()

local task_model = {}


function task_model:query_all()
   local res, err =  db:query("select * from fake_task ")
   return res, err
end


function task_model:query_by_id(id)
    local result, err =  db:query("select * from fake_task where id=?", {id})
    if not result or err or type(result) ~= "table" or #result ~=1 then
        return nil, err
    else
        return result[1], err
    end
end

function task_model:new(p)
    return db:query("insert into fake_task(name, start_time, end_time, ulimit, cpm, url, status) values(?,?,?,?,?,?,?)",
            {p.name, p.start_time, p.end_time, p.ulimit, p.cpm, p.url, p.status})
end

function task_model:delete(id)
    return db:query("delete from fake_task where id=?", {id})
end


function task_model:update(id, p)
    local keys = {}
    local values = {}

    for k,v in pairs(p) do
        table.insert(keys, k)
        table.insert(values, v)
    end
    
    table.insert(values, id)

    local query_params = table.concat(keys, "=?, ")
    query_params = query_params .. "=?"
    
    local query_str = string.format("update fake_task set %s where id=?", query_params)
    
    ngx.log(ngx.INFO, "query_str:", query_str)
    
    local res, err = db:query(query_str, values)

    return res, err
end

function task_model:query_valid()
    query_str = string.format("select * from fake_task where status=1 and times_need > times_finish and end_time > '%s' and start_time < '%s'", 
           ngx.localtime(), ngx.localtime())
    
    local res, err = db:query(query_str)
    
    return res, err
end

-- function task_model:set_finished(id)
    -- query_str = string.format("update fake_task set status=0 where id=%d", id)
    
    -- local res, err = db:query(query_str)
    
    -- return res, err
-- end

function task_model:get_total_count()
    local res, err = db:query("select count(id) as c from fake_task")

    if err or not res or #res~=1 or not res[1].c then
        return 0
    else
        return res[1].c
    end
end

return task_model
