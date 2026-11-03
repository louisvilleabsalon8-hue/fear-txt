-- Fear Texture Pack | Delta Lua
-- Applies supported Roblox asset-ID replacements to instances visible to this client.
-- CDN-image rules from the JSON are not included: Roblox texture properties need
-- Roblox asset IDs, not arbitrary GitHub image URLs.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Replacements = {
    ["7658055825"] = "92454874326684",\n    ["14147881297"] = "18703232671",\n    ["14147881792"] = "18703245834",\n    ["14147882149"] = "18703243349",\n    ["14147882405"] = "18703235430",\n    ["14147882761"] = "18703240532",\n    ["14147883091"] = "18703237556",\n}

local RemoveIds = {
    ["2108482005"] = true,\n    ["2108482231"] = true,\n    ["2108482395"] = true,\n    ["2108482542"] = true,\n    ["2108482676"] = true,\n    ["2108545280"] = true,\n    ["10196549902"] = true,\n    ["10196550128"] = true,\n    ["10196550367"] = true,\n    ["10196550667"] = true,\n    ["10196550937"] = true,\n    ["10196567794"] = true,\n    ["12261809766"] = true,\n    ["12261813110"] = true,\n    ["12261813678"] = true,\n    ["13854780213"] = true,\n    ["72960281658487"] = true,\n    ["84214501374682"] = true,\n    ["89972436184102"] = true,\n    ["92138082970751"] = true,\n    ["103020541883227"] = true,\n    ["135908632589654"] = true,\n}

local SkyFaces = {
    SkyboxBk = "14147881792",
    SkyboxDn = "14147882149",
    SkyboxFt = "14147882761",
    SkyboxLf = "14147883091",
    SkyboxRt = "14147882405",
    SkyboxUp = "14147881297",
}

local function assetId(value)
    if type(value) ~= "string" then
        return nil
    end
    return value:match("(%d+)")
end

local function replaceProperty(object, property)
    local ok, value = pcall(function()
        return object[property]
    end)
    if not ok or type(value) ~= "string" then
        return
    end

    local id = assetId(value)
    if not id then
        return
    end

    local replacement = Replacements[id]
    if replacement then
        pcall(function()
            object[property] = "rbxassetid://" .. replacement
        end)
    elseif RemoveIds[id] then
        -- Clear removable image/texture references where the property permits it.
        pcall(function()
            object[property] = ""
        end)
    end
end

local function process(object)
    if object:IsA("Decal") or object:IsA("Texture") then
        replaceProperty(object, "Texture")
    end

    if object:IsA("MeshPart") then
        replaceProperty(object, "TextureID")
    elseif object:IsA("SpecialMesh") then
        replaceProperty(object, "TextureId")
    end

    if object:IsA("Sky") then
        for property, oldId in pairs(SkyFaces) do
            local ok, value = pcall(function()
                return object[property]
            end)
            if ok and assetId(value) == oldId then
                local replacement = Replacements[oldId]
                if replacement then
                    pcall(function()
                        object[property] = "rbxassetid://" .. replacement
                    end)
                end
            end
        end
    end
end

-- Process currently loaded content.
for _, object in ipairs(game:GetDescendants()) do
    process(object)
end

-- Process content created or streamed in later.
game.DescendantAdded:Connect(function(object)
    task.defer(process, object)
end)

-- Also watch Lighting for newly-created sky objects.
Lighting.DescendantAdded:Connect(function(object)
    task.defer(process, object)
end)

print("[Fear Texture Pack] Supported ID replacements applied.")
