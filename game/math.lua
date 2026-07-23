function math.clamp(x, low, high)
    if x < low then
        return low
    elseif x > high then
        return high
    else
        return x
    end
end
