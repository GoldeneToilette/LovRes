local vector = {}

-- Creates a new Vector3D
function vector.new(x, y, z)
    return {x or 0, y or 0, z or 0}
end

function vector.negate(v)
    return { -v[1], -v[2], -v[3] }
end

-- Adds two vectors
function vector.add(v1, v2)
    return vector.new(v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3])
end

-- Subtracts two vectors
function vector.subtract(v1, v2)
    return vector.new(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3])
end

-- Multiplies a vector by a scalar
function vector.scalar(scalar, v)
    return vector.new(v[1] * scalar, v[2] * scalar, v[3] * scalar)
end

-- Cross product of two vectors
function vector.cross(v1, v2)
    return vector.new(
        (v1[2] * v2[3]) - (v1[3] * v2[2]),
        (v1[3] * v2[1]) - (v1[1] * v2[3]),
        (v1[1] * v2[2]) - (v1[2] * v2[1])
    )
end

-- Dot product of two vectors
function vector.dot(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

-- Magnitude of a vector
function vector.magnitude(v)
    return math.sqrt(v[1] * v[1] + v[2] * v[2] + v[3] * v[3])
end

-- Normalize a vector (make its magnitude 1)
function vector.normalize(v)
    local mag = vector.magnitude(v)
    if mag ~= 0 then
        return vector.new(v[1] / mag, v[2] / mag, v[3] / mag)
    else
        return vector.new(0, 0, 0)
    end
end

-- Linear interpolation between two vectors
function vector.lerp(v1, v2, t)
    return vector.new(
        (1 - t) * v1[1] + t * v2[1],
        (1 - t) * v1[2] + t * v2[2],
        (1 - t) * v1[3] + t * v2[3]
    )
end

return vector
