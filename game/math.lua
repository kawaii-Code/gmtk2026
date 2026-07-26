function math.clamp(x, low, high)
    if x < low then
        return low
    elseif x > high then
        return high
    else
        return x
    end
end

function math.sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end
