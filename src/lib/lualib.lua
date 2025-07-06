function table.removeValue(t, value)
    for i = 1, #t do
        if t[i] == value then
            table.remove(t, i)
            return true
        end
    end
    return false
end

function table.clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end
