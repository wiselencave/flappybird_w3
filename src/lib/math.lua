function math.countDigits(n)
    local count = 0
    repeat count = count + 1
        n = math.floor(n / 10)
    until n == 0
    return count
end

function math.getDigits(n, t)
    repeat
        table.insert(t, 1, n % 10)
        n = math.floor(n / 10)
    until n == 0
end

function math.getDivisibleNumber(n, divisor)
    return math.ceil(n / divisor) * divisor
end