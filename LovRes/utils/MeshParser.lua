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

-- parse a file
function MeshParser.parse(path)
    if not fileExists(path) then return nil, "File does not exist!" end

    local ext = path:match("^.+(%.[^%.]+)$")
    local parser = MeshParser.parsers[ext]

    if parser then
        return parser(path)
    else
        return "Unsupported mesh format!"
    end
end

-- parse .obj file
function MeshParser.obj(path)
    local positions = {}
    local normals = {}
    local uvs = {}

    local sortedVertices = {}

    for line in love.filesystem.lines(path) do
            -- split the lines into parts
            local parts = {}
            for part in line:gmatch("%S+") do
                table.insert(parts, part)
            end

            -- determines type and puts it in the tables accordingly
            if parts[1] == "v" then
                table.insert(positions, {tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])})
            elseif parts[1] == "vt" then
                table.insert(uvs, {tonumber(parts[2]), tonumber(parts[3])})
            elseif parts[1] == "vn" then
                table.insert(normals, {tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4])})
            -- f: v/vt/vn
            elseif parts[1] == "f" then
                local vertices = {}
                for i = 2, #parts do
                    local v, vt, vn = parts[i]:match("(%d*)/(%d*)/(%d*)")
                    v, vt, vn = tonumber(v), tonumber(vt), tonumber(vn)
                    table.insert(vertices, {
                        v and positions[v][1] or 0,
                        v and positions[v][2] or 0,
                        v and positions[v][3] or 0,
                        vt and uvs[vt][1] or 0,
                        vt and uvs[vt][2] or 0,
                        vn and normals[vn][1] or 0,
                        vn and normals[vn][2] or 0,
                        vn and normals[vn][3] or 0,
                    })
                end

                -- it triangulates the faces
                if #vertices > 3 then
                    -- choose a central vertex
                    local centralVertex = vertices[1]
    
                    -- connect the central vertex to each of the other vertices to create triangles
                    for i = 2, #vertices - 1 do
                        table.insert(sortedVertices, centralVertex)
                        table.insert(sortedVertices, vertices[i])
                        table.insert(sortedVertices, vertices[i + 1])
                    end
                else
                    for i = 1, #vertices do
                        table.insert(sortedVertices, vertices[i])
                    end
                end
                
            end
    end

    return sortedVertices
end

return MeshParser