-- Will handle various mesh formats in the future, only .obj for now. Parses the file and returns it as a table
local MeshParser = {}

-- lookup table with callbacks (making an if chain felt wrong)
MeshParser.parsers = {
    [".obj"] = function(file)
        return MeshParser.obj(file)
    end,
}

local function fileExists(path)
    local info = love.filesystem.getInfo(path)
    return info and info.type == "file"
end

-- Picks the correct parsing function from the lookup table (only .obj rn)
function MeshParser.parse(path)
    if not fileExists(path) then return error("File does not exist!") end

    local ext = path:match("^.+(%.[^%.]+)$")
    local parser = MeshParser.parsers[ext]

    if parser then
        return parser(path)
    else
        return "Unsupported mesh format!"
    end
end

-- compare vertices
local function compareVertices(v1, v2)
    return v1[1][1] == v2[1][1] and v1[1][2] == v2[1][2] and v1[1][3] == v2[1][3] and
           v1[2][1] == v2[2][1] and v1[2][2] == v2[2][2] and
           v1[3][1] == v2[3][1] and v1[3][2] == v2[3][2] and v1[3][3] == v2[3][3]
end

-- Parser for .obj files
function MeshParser.obj(path)
    local positions = {}
    local normals = {}
    local uvs = {}

    local uniqueVertices = {}
    local vertexMap = {}

    for line in love.filesystem.lines(path) do
        -- Split the line into parts
        local parts = {}
        for part in line:gmatch("%S+") do
            table.insert(parts, part)
        end

        -- parse vertex data
        if parts[1] == "v" then
            table.insert(positions, {tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])})
        elseif parts[1] == "vt" then
            table.insert(uvs, {tonumber(parts[2]), tonumber(parts[3])})
        elseif parts[1] == "vn" then
            table.insert(normals, {tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])})
        -- parse faces
        elseif parts[1] == "f" then
            local faceVertices = {}
            
            -- parse each vertex in the face
            for i = 2, #parts do
                local v, vt, vn = parts[i]:match("(%d*)/(%d*)/(%d*)")
                v, vt, vn = tonumber(v), tonumber(vt), tonumber(vn)

                -- default values for missing UVs or normals
                local uv = vt and uvs[vt] or {0, 0}
                local normal = vn and normals[vn] or {0, 0, 1}

                -- create unique key for vertex
                local vertexKey = {positions[v], uv, normal}

                -- check if vertex already exists
                local vertexIndex = nil
                for idx, existingVertex in ipairs(uniqueVertices) do
                    if compareVertices(existingVertex, vertexKey) then
                        vertexIndex = idx
                        break
                    end
                end

                -- if its not in there, add it
                if not vertexIndex then
                    vertexIndex = #uniqueVertices + 1
                    table.insert(uniqueVertices, vertexKey)
                end

                -- add index to the map
                table.insert(faceVertices, vertexIndex)
            end

            -- triangulate quads
            if #faceVertices == 4 then
                table.insert(vertexMap, faceVertices[1])
                table.insert(vertexMap, faceVertices[2])
                table.insert(vertexMap, faceVertices[3])
            
                table.insert(vertexMap, faceVertices[1])
                table.insert(vertexMap, faceVertices[3])
                table.insert(vertexMap, faceVertices[4])
            elseif #faceVertices == 3 then
                -- already a triangle
                table.insert(vertexMap, faceVertices[1])
                table.insert(vertexMap, faceVertices[2])
                table.insert(vertexMap, faceVertices[3])
            elseif #faceVertices > 4 then
                error("Unsupported n-gon face detected with " .. #faceVertices .. " vertices! As of right now only triangles and quads are supported")
            end
        end
    end

    -- prepare the vertices
    local finalVertices = {}
    for _, vertex in ipairs(uniqueVertices) do
        local position = vertex[1]
        local uv = vertex[2]
        local normal = vertex[3]

        -- create a table according to the vertex format
        table.insert(finalVertices, {position[1], position[2], position[3], uv[1], uv[2], normal[1], normal[2], normal[3]})
    end

    return finalVertices, vertexMap
end

return MeshParser