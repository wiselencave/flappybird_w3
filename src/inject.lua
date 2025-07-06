local function mainInject(funcMain, funcConfig)
    local mt = getmetatable(_G) or {}
    if not getmetatable(_G) then
        setmetatable(_G, mt)
    end

    local originalConfig
    local injected = {config = false, main = false}

    mt.__newindex = function(tbl, key, val)
        if key == "config" and not injected.config then
            originalConfig = val
            rawset(tbl, key, function(...)
                originalConfig(...)
                funcConfig(...)
            end)
            injected.config = true
        elseif key == "main" and not injected.main then
            rawset(tbl, key, funcMain)
            injected.main = true
        else
            rawset(tbl, key, val)
        end

        if injected.config and injected.main then
            mt.__newindex = nil
        end
    end
end

mainInject(customMain, customConfig)
