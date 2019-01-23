
-- XX my local path
local my_local_dir = "/home/dou/work/git/doujiang/lua-resty-balancer/"

package.path = my_local_dir .. "lib/?.lua;" .. package.path
package.cpath = my_local_dir .. "?.so;" .. package.cpath

local base_time

-- should run typ = nil first
local function bench(num, name, func, typ, ...)
    ngx.update_time()
    local start = ngx.now()

    for i = 1, num do
        func(...)
    end

    ngx.update_time()
    local elasped = ngx.now() - start

    if typ then
        elasped = elasped - base_time
    end

    ngx.say(name)
    ngx.say(num, " times")
    ngx.say("elasped: ", elasped)
    ngx.say("")

    if not typ then
        base_time = elasped
    end
end


local resty_chash = require "resty.chash"

local servers = {
    ["server1"] = 10,
    ["server2"] = 2,
    ["server3"] = 1,
}

local servers2 = {
    ["server1"] = 100,
    ["server2"] = 20,
    ["server3"] = 10,
}

local servers3 = {
    ["server0"] = 1,
    ["server1"] = 1,
    ["server2"] = 1,
    ["server3"] = 1,
    ["server4"] = 1,
    ["server5"] = 1,
    ["server6"] = 1,
    ["server7"] = 1,
    ["server8"] = 1,
    ["server9"] = 1,
    ["server10"] = 1,
    ["server11"] = 1,
    ["server12"] = 1,
}

local chash = resty_chash:new(servers)

local function gen_func(typ)
    local i = 0

    if typ == 0 then
        return function ()
            i = i + 1

            resty_chash:new(servers)
        end
    end

    if typ == 1 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
        end
    end

    if typ == 2 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:incr("server3" .. i)
        end, typ
    end

    if typ == 3 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:incr("server1" .. i)
        end, typ
    end

    if typ == 4 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:decr("server1" .. i)
        end, typ
    end

    if typ == 5 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:delete("server3" .. i)
        end, typ
    end

    if typ == 6 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:delete("server1" .. i)
        end, typ
    end

    if typ == 7 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:set("server1" .. i, 9)
        end, typ
    end

    if typ == 8 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:set("server1" .. i, 8)
        end, typ
    end

    if typ == 9 then
        return function ()
            i = i + 1

            local servers = {
                ["server1" .. i] = 10,
                ["server2" .. i] = 2,
                ["server3" .. i] = 1,
            }
            local chash = resty_chash:new(servers)
            chash:set("server1" .. i, 1)
        end, typ
    end

    if typ == 100 then
        return function ()
            i = i + 1
        end
    end

    if typ == 101 then
        return function ()
            i = i + 1

            chash:find(i)
            i = i + 1
        end, typ
    end

    if typ == 102 then
        return function ()
            i = i + 1

            chash:simple_find(i)
        end, typ
    end
end

bench(10 * 1000, "chash new servers", resty_chash.new, nil, nil, servers)
bench(1 * 1000, "chash new servers2", resty_chash.new, nil, nil, servers2)
bench(10 * 1000, "chash new servers3", resty_chash.new, nil, nil, servers3)
bench(10 * 1000, "new in func", gen_func(0))
bench(10 * 1000, "new dynamic", gen_func(1))
bench(10 * 1000, "incr server3", gen_func(2))
bench(10 * 1000, "incr server1", gen_func(3))
bench(10 * 1000, "decr server1", gen_func(4))
bench(10 * 1000, "delete server3", gen_func(5))
bench(10 * 1000, "delete server1", gen_func(6))
bench(10 * 1000, "set server1 9", gen_func(7))
bench(10 * 1000, "set server1 8", gen_func(8))
bench(10 * 1000, "set server1 1", gen_func(9))

bench(1000 * 1000, "base for find", gen_func(100))
bench(1000 * 1000, "find", gen_func(101))
