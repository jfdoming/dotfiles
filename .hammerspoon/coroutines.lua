-- Thanks to https://luyuhuang.tech/2020/09/13/callback-to-coroutine.html
local function invoke(f, cb, ...)
    local co = coroutine.create(f)
    local function exec(...)
        local ok, data = coroutine.resume(co, ...)
        if not ok then
            error(debug.traceback(co, data))
        end
        if coroutine.status(co) ~= "dead" then
            data(exec)
        else
            cb(data)
        end
    end
    exec(...)
end

local function yield(fn, ...)
    local args = {...}
    return coroutine.yield(function(resolve)
        fn(resolve, table.unpack(args))
    end)
end

local function coroutinize(fn)
    return function(cb, ...)
        return invoke(fn, cb, ...)
    end
end

local function bind(fn, self)
    return function(...)
        return fn(self, ...)
    end
end

local noop = function() end

local meta = {
    __call = function(self, fn)
        return function(...)
            return invoke(fn, noop, ...)
        end
    end,
}

local self = {
    coroutinize = coroutinize,
    invoke = invoke,
    yield = yield,
    bind = bind,
}
setmetatable(self, meta)
return self
