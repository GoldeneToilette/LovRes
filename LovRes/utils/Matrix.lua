local vector = require "LovRes.utils.Vector3D"

local matrix = {}
matrix.__index = matrix
-- A matrix is basically just a set of "numbers" that can be applied to a vector to get a new vector.
-- (at least in 3d rendering context)
-- NOTE: the matrices in this class are row-major

-- default matrix, anything multiplied by an identity matrix returns an identity matrix
matrix.identityMatrix = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}

-- create new matrix 
function matrix.new()
    local self = setmetatable({}, matrix)    
    self[1], self[2], self[3], self[4], 
    self[5], self[6], self[7], self[8], 
    self[9], self[10], self[11], self[12], 
    self[13], self[14], self[15], self[16] = unpack(matrix.identityMatrix)
    return self
end

-- addition
function matrix.__add(a, b)
    assert(#a == #b, "Matrix dimensions must match!")
    local result = matrix.new()
    for i = 1, 16 do
        result[i] = a[i] + b[i]
    end
    return result
end

-- multiplication
function matrix.__mul(a, b)
    if getmetatable(b) == matrix then
        -- Matrix-matrix multiplication
        return a:multiplyMatrix(b)
    elseif type(b) == "table" and #b == 3 then
        -- Matrix-vector multiplication
        return a:multiplyVector(b)
    else
        error("Unsupported multiplication types!")
    end
end

-- This function prints the matrix in a 4x4 format
function matrix:toString()
    local matrixStr = ""
    for i = 1, 4 do
        local row = {}
        for j = 1, 4 do
            table.insert(row, string.format("%.2f", self[(i - 1) * 4 + j]))
        end
        matrixStr = matrixStr .. table.concat(row, "  ") .. "\n"
    end
    return matrixStr
end

-- Converts Euler angles to quaternion
function matrix.eulerToQuaternion(rx, ry, rz)
    local halfRx = rx * 0.5
    local halfRy = ry * 0.5
    local halfRz = rz * 0.5

    local cosRx = math.cos(halfRx)
    local sinRx = math.sin(halfRx)
    local cosRy = math.cos(halfRy)
    local sinRy = math.sin(halfRy)
    local cosRz = math.cos(halfRz)
    local sinRz = math.sin(halfRz)

    local w = cosRx * cosRy * cosRz + sinRx * sinRy * sinRz
    local x = sinRx * cosRy * cosRz - cosRx * sinRy * sinRz
    local y = cosRx * sinRy * cosRz + sinRx * cosRy * sinRz
    local z = cosRx * cosRy * sinRz - sinRx * sinRy * cosRz

    return w, x, y, z
end

-- Converts a quaternion to Euler
function matrix.quaternionToEuler(w, x, y, z)
    local roll = math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
    local pitch = math.asin(2 * (w * y - z * x))
    local yaw = math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))

    return roll, pitch, yaw
end

-- checks if a matrix is an identity matrix
function matrix:isIdentity()
    for i = 1, 16 do
        if self[i] ~= matrix.identityMatrix[i] then
            return false
        end
    end
    return true
end

-- multiplies two matrices with eachother
function matrix:multiplyMatrix(matrix2)
    -- if an identity matrix is present skip calculations
    if self:isIdentity() then return matrix2 end
    if matrix2:isIdentity() then return self end
    
    local result = matrix.new()

    for i = 1, 4 do
        for j = 1, 4 do
            local sum = 0
            for k = 1, 4 do
                sum = sum + self[(i - 1) * 4 + k] * matrix2[(k - 1) * 4 + j]
            end
            result[(i - 1) * 4 + j] = sum
        end
    end
    return result
end

-- multiplies a matrix with a vector3D (returns a new vector)
function matrix:multiplyVector(v)
    if self:isIdentity() then return {v[1], v[2], v[3], 1} end
    local v4d = {v[1], v[2], v[3], 1}
    local result = {0, 0, 0, 0}

    result[1] = self[1] * v4d[1] + self[2] * v4d[2] + self[3] * v4d[3] + self[4] * v4d[4]
    result[2] = self[5] * v4d[1] + self[6] * v4d[2] + self[7] * v4d[3] + self[8] * v4d[4]
    result[3] = self[9] * v4d[1] + self[10] * v4d[2] + self[11] * v4d[3] + self[12] * v4d[4]
    result[4] = self[13] * v4d[1] + self[14] * v4d[2] + self[15] * v4d[3] + self[16] * v4d[4]
    return result
end

-- a transformation matrix defines how each vector (vertex) of an object behaves
-- Basically, you apply translation, rotation and scale to each of the vertices
-- transformation order is: scaling -> rotation -> translation
function matrix:setTransform(translation, rotation, scale)
    assert(#translation == 3, "Translation must have 3 elements")
    assert(#rotation == 3, "Rotation must have 3 elements")
    assert(#scale == 3, "Scale must have 3 elements")    

    -- translation
    self[4], self[8], self[12] = translation[1], translation[2], translation[3]

    
    -- Quaternion components
    -- Function takes euler angles as input and transforms it to quaternions internally
    -- this way the user doesnt have to deal with quaternion bs while avoiding gimbal lock
    local w, x, y, z = matrix.eulerToQuaternion(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))

    -- if no rotation is provided it skips the calculations
    if not (w == 1 and x == 0 and y == 0 and z == 0) then
        -- prevents distortion
        local mag = math.sqrt(w * w + x * x + y * y + z * z)
        if mag > 0 then
            w, x, y, z = w / mag, x / mag, y / mag, z / mag
        end

        -- rotation matrix is the 3x3 matrix in the top left of the 4x4 matrix
        -- here i derive the matrix from the quaternion components
        self[1] = 1 - 2 * (y * y + z * z)
        self[2] = 2 * (x * y - w * z)
        self[3] = 2 * (x * z + w * y)

        self[5] = 2 * (x * y + w * z)
        self[6] = 1 - 2 * (x * x + z * z)
        self[7] = 2 * (y * z - w * x)

        self[9] = 2 * (x * z - w * y)
        self[10] = 2 * (y * z + w * x)
        self[11] = 1 - 2 * (x * x + y * y)
    end

    -- Scale is only applied to rotation matrix since its easier to perform multiplication on a 3x3 matrix 
    self[1], self[2],  self[3]  = self[1] * scale[1], self[2]  * scale[2], self[3]  * scale[3]
    self[5], self[6],  self[7]  = self[5] * scale[1], self[6]  * scale[2], self[7]  * scale[3]
    self[9], self[10], self[11] = self[9] * scale[1], self[10] * scale[2], self[11] * scale[3]

    self[13], self[14], self[15], self[16] = 0, 0, 0, 1
end

-- Makes distant objects appear smaller and closer objects bigger
function matrix:perspectiveMatrix(fov, aspect, near, far)
    assert(near > 0 and far > near, "Invalid perspective parameters: Ensure far > near > 0.")
    local top = near * math.tan(fov/2)
    local bottom = -1*top
    local right = top * aspect
    local left = -1*right

    self[1],  self[2],  self[3],  self[4]  = 2*near/(right-left), 0, (right+left)/(right-left), 0
    self[5],  self[6],  self[7],  self[8]  = 0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0
    self[9],  self[10], self[11], self[12] = 0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near)
    self[13], self[14], self[15], self[16] = 0, 0, -1, 0
end

-- maintains parallel lines and does not distort the perspective
-- useful for 2D games or when you need a uniform scale 
function matrix:orthographicMatrix(fov, aspect, near, far, size)
    local top = size * math.tan(fov/2)
    local bottom = -1*top
    local right = top * aspect
    local left = -1*right

    self[1],  self[2],  self[3],  self[4]  = 2/(right-left), 0, 0, -1*(right+left)/(right-left)
    self[5],  self[6],  self[7],  self[8]  = 0, 2/(top-bottom), 0, -1*(top+bottom)/(top-bottom)
    self[9],  self[10], self[11], self[12] = 0, 0, -2/(far-near), -(far+near)/(far-near)
    self[13], self[14], self[15], self[16] = 0, 0, 0, 1
end

-- sets up the view matrix for the camera (world position, etc)
function matrix:viewMatrix(position, lookAt, up)
    assert(#position == 3 and #lookAt == 3 and #up == 3, "All arguments must be 3D vectors!")
    local z = vector.normalize(vector.subtract(position, lookAt))
    local x = vector.normalize(vector.cross(up, z))
    local y = vector.cross(z, x)

    self[1], self[2], self[3], self[4] = x[1], x[2], x[3], -1*vector.dot(x, position)
    self[5], self[6], self[7], self[8] = y[1], y[2], y[3], -1*vector.dot(y, position)
    self[9], self[10], self[11], self[12] = z[1], z[2], z[3], -1*vector.dot(z, position)
    self[13], self[14], self[15], self[16] = 0, 0, 0, 1
end

return matrix
